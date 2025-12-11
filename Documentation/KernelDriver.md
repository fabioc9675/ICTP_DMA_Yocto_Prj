# **📘 Guía completa: Driver AXI-Lite (Slow Control) en Kria KR260 + PetaLinux 2022.2**

Esta guía documenta **todos los pasos que funcionaron correctamente** para crear, compilar, cargar y probar un driver Linux (`slow_control.ko`) que maneja un periférico AXI-Lite en la Kria KR260, usando device-tree overlay, sysfs y acceso directo a registros.

Incluye:

* 🧩 Preparación del entorno
* 🏗️ Construcción del módulo del kernel
* 📡 Transferencia y carga en la Kria
* 🧪 Pruebas reales leyendo/escribiendo registros
* 🧱 Código completo del driver
* 🛠 Makefile final validado

---

# **1. Arquitectura del proyecto**

El diseño PL contenía:

| IP                         | Dirección     | Tipo                                                   |
| -------------------------- | -------------- | ------------------------------------------------------ |
| **Slow Control AXI** | `0x80020000` | Periférico AXI-Lite (control personalizado)           |
| **AXI DMA**          | `0x80010000` | Xilinx AXI DMA (driver estándar ya presente en Linux) |

Además se generó un **device-tree overlay** (`axi_full_ictp.dtbo`) que declara ambos periféricos.

---

# **2. Verificar Overlay cargado en la Kria**

La Kria usa `xmutil`:

```bash
xmutil listapps
xmutil loadapp <appname>
```

Verificar que el overlay está aplicado:

```bash
ls /configfs/device-tree/overlays/
cat /configfs/device-tree/overlays/axi_full_ictp_image_1/status
```

Debe mostrar:

```
applied
```

Confirmar que el nodo del slow-control existe:

```bash
ls /sys/firmware/devicetree/base/axi/
ls /sys/firmware/devicetree/base/axi/slow_control_axi@80020000
```

Ver dirección física:

```bash
hexdump /sys/firmware/devicetree/base/axi/slow_control_axi@80020000/reg
```

---

# **3. Preparación del SDK para compilar módulos**

En el host Linux donde está el proyecto Petalinux:

```bash
petalinux-build --sdk
petalinux-build -c kernel -x compile

cd build/tmp/deploy/sdk
chmod +x petalinux-glibc-x86_64-petalinux-image-minimal-cortexa72-cortexa53-xilinx-k26-kr-toolchain-2022.2.sh
./petalinux-glibc-x86_64-petalinux-image-minimal-cortexa72-cortexa53-xilinx-k26-kr-toolchain-2022.2.sh
```

Luego en cada sesión:

```bash
source /opt/petalinux/2022.2/environment-setup-cortexa72-cortexa53-xilinx-linux
```

---

# **4. Ubicación del kernel build para compilar módulos**

Los artefactos del kernel están aquí:

```
build/tmp/work-shared/xilinx-k26-kr/kernel-build-artifacts/
```

Lo usaremos como `KDIR`.

---

# **5. Código completo del driver (slow_control.c)**

Incluye soporte para múltiples registros, sysfs dinámico, create/remove limpio e integración con device-tree.

---

## 📄 slow_control.c, el que funcionó

```c
#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/of.h>
#include <linux/io.h>
#include <linux/sysfs.h>
#include <linux/slab.h>

#define NUM_REGS 16   // <-- AJUSTA según tus registros AXI-Lite

static void __iomem *regs_base;

/* -------------------- SYSFS SHOW -------------------- */
static ssize_t reg_show(struct device *dev,
                        struct device_attribute *attr, char *buf)
{
    unsigned long offset;
    u32 value;

    if (kstrtoul(attr->attr.name + 3, 10, &offset))
        return -EINVAL;

    value = ioread32(regs_base + offset * 4);
    return sprintf(buf, "%u\n", value);
}

/* -------------------- SYSFS STORE -------------------- */
static ssize_t reg_store(struct device *dev,
                         struct device_attribute *attr,
                         const char *buf, size_t count)
{
    unsigned long offset, value;

    if (kstrtoul(attr->attr.name + 3, 10, &offset))
        return -EINVAL;

    if (kstrtoul(buf, 0, &value))
        return -EINVAL;

    iowrite32((u32)value, regs_base + offset * 4);
    return count;
}

/* ----- Creamos un arreglo dinámico de atributos sysfs ----- */
static struct device_attribute *reg_attrs[NUM_REGS];

/* -------------------- PROBE -------------------- */
static int slow_ctrl_probe(struct platform_device *pdev)
{
    struct resource *res;
    int i, ret;

    dev_info(&pdev->dev, "probe() called\n");

    res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
    regs_base = devm_ioremap_resource(&pdev->dev, res);
    if (IS_ERR(regs_base))
        return PTR_ERR(regs_base);

    dev_info(&pdev->dev, "regs mapped at %p (phys 0x%pa)\n",
             regs_base, &res->start);

    /* Crear atributos reg0…reg15 */
    for (i = 0; i < NUM_REGS; i++) {
        reg_attrs[i] = devm_kzalloc(&pdev->dev,
                                    sizeof(struct device_attribute),
                                    GFP_KERNEL);
        if (!reg_attrs[i])
            return -ENOMEM;

        /* crear nombre dinámico */
        reg_attrs[i]->attr.name = devm_kasprintf(&pdev->dev,
                                                 GFP_KERNEL,
                                                 "reg%d", i);
        reg_attrs[i]->attr.mode = 0664;
        reg_attrs[i]->show = reg_show;
        reg_attrs[i]->store = reg_store;

        ret = device_create_file(&pdev->dev, reg_attrs[i]);
        if (ret) return ret;
    }

    dev_info(&pdev->dev, "slow_control driver initialized!\n");
    return 0;
}

/* -------------------- REMOVE -------------------- */
static int slow_ctrl_remove(struct platform_device *pdev)
{
    int i;
    for (i = 0; i < NUM_REGS; i++)
        if (reg_attrs[i])
            device_remove_file(&pdev->dev, reg_attrs[i]);

    return 0;
}

/* ---- DT Compatible ---- */
static const struct of_device_id slow_ctrl_of_match[] = {
    { .compatible = "xlnx,slow-control-axi-1.0", },
    {}
};
MODULE_DEVICE_TABLE(of, slow_ctrl_of_match);

static struct platform_driver slow_ctrl_driver = {
    .probe = slow_ctrl_probe,
    .remove = slow_ctrl_remove,
    .driver = {
        .name           = "slow_control",
        .of_match_table = slow_ctrl_of_match,
    },
};

module_platform_driver(slow_ctrl_driver);
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Fabian Castaño");
MODULE_DESCRIPTION("AXI Slow Control multi-register driver");
```

---

# **6. Makefile final**

Guárdalo como:

**`Makefile`**

```makefile
obj-m += slow_control.o

# Ruta al árbol del kernel de PetaLinux
KDIR := /home/fcastano/Documents/Kria_Petalinux/linux_os/build/tmp/work-shared/xilinx-k26-kr/kernel-build-artifacts

all:
        $(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
        $(MAKE) -C $(KDIR) M=$(PWD) clean

```

---

# **7. Compilación en el host**

```bash
make -j$(nproc)
```

Resultado:

```
slow_control.ko
```

---

# **8. Copiar a la Kria**

```bash
scp -O slow_control.ko petalinux@<IP>:/home/petalinux/
```

---

# **9. Instalar módulo**

Primero quitar módulo previo:

```bash
sudo rmmod slow_control
```

Luego instalar:

```bash
sudo insmod slow_control.ko
```

Ver logs:

```bash
dmesg | tail -20
```

Debes ver:

```
probe() called
regs mapped at ...
slow_control driver initialized!
```

---

# **10. Usar el driver**

Ver el dispositivo:

```bash
ls /sys/bus/platform/devices/80020000.slow_control_axi/
```

Ejemplo leer registro 0:

```bash
cat /sys/bus/platform/devices/80020000.slow_control_axi/reg1
```

Ejemplo escribir:

```bash
echo 1 | sudo tee /sys/bus/platform/devices/80020000.slow_control_axi/reg3
```

---
