# Compilación de DTO

para compilar el Device Tree Overlay se utiliza la herramienta `xsct` de Vitis, esta compilacion debe hacerse en Linux a traves de la terminal. Los comandos para realizar la compilacion son los siguientes:

```bash
# descomprime la plataforma creada en Vivado, debe incluir el bitstream
hsi::open_hw_design kria_bd_wrapper.xsa  

# Usa la herramienta de Xilinx descargada desde GitHub para crear el descriptoor de Device Tree
createdts -hw kria_bd_wrapper.xsa -zocl -platform-name ictp_dma -git-branch xlnx_rel_v2022.2 -overlay -compile -out ./dtg_kr260_v0

# Salir de XSCT
exit

```

Ahora lo que sigue es copiar el archivo `pl.dtsi` que se encuentra en la ruta `$~/kria_ictp_dma/dtg_kr260_v0/dtg_kr260_v0/ictp_dma/psu_cortexa53_0/device_tree_domain/bsp/` y llevaro a la carpeta `FileTransfer`

dentro de la carpeta `FileTransfer` debe convertirse el archivo `pl.dtsi` en el archivo `ictp_dma.dtbo` el cual es el device tree overlay, esto se realiza con el siguiente comando:

```bash
dtc -@ -O dtb -o ictp_dma.dtbo pl.dtsi
```

y se debe cambiar el nombre del bitstream a `ictp_dma.bit.bin` 

```bash
mv kria_bd_wrapper.bit ictp_dma.bit.bin
```

Finalmente, se debe crear un archivo `shell.json con el siguiente contenido`

```bash
{
  "shell_type": "XRT_FLAT",
  "num_slots": "1"
}
```

Luego estos tres archivos se envian al sistema Petalinux (En mi caso Kria KR260) y se debe copiar a la carpeta `/lib/firmware/xilinx/ictp_dma/`
