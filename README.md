# NOB-PTLF-M5SBC
NOB-PTLF-M5SBC U-Boot &amp; Kernel patch

## Environment
- Ubuntu 20.04
- MTK IoT Yocto: v25.1

## File Tree
```
NOB-PTLF-M5SBC/
├── nob-ptlf-m5sbc-patch/
│   ├── kernel/
|   |   ├── defconfig
|   |   └── kernel-nob-ptlf-m5sbc-4g.patch
|   |
|   └── u-boot/
|       └── nob-ptlf-m5sbc-2g.patch
|
├── tools/
│   ├── lancfg.sh
│   └── smarcCfg
│
└── README.md
```
## U-boot Patch (Only for 2GB board)
- Please copy the `u-boot/nob-ptlf-m5sbc-2g.patch` to `$BUILD_DIR/tmp/work/genio_510_evk-poky-linux/u-boot/git/git`
- Run patch apply
    ```shell=!
    # For error check (Won't patch)
    git apply --check nob-ptlf-m5sbc-2g.patch

    # if there is no error, patch file
    git apply nob-ptlf-m5sbc-2g.patch
    ```
- Re-build the u-boot
    ```shell=!
    bitbake u-boot
    ```
## Kernel Patch
- Please copy the `kernel/kernel-nob-ptlf-m5sbc-4g.patch` to `$BUILD_DIR/tmp/work/genio_510_evk-poky-linux/linux-mtk/6.6.92/git`
- Run patch apply
    ```shell=!
    # For error check (Won't patch)
    git apply --check kernel-nob-ptlf-m5sbc-4g.patch

    # if there is no error, patch file
    git apply kernel-nob-ptlf-m5sbc-4g.patch
   ```
- Re-build the kernel
    ```shell=!
    bitbake linux-mtk -c compile -f
    bitbake linux-mtk -c deploy -f
    ```

### Kernel DDR setup
- To change 4GB DDR to 2GB DDR, please modify `$BUILD_DIR/tmp/work/genio_510_evk-poky-linux/linux-mtk/6.6.92/git/arch/arm64/boot/dts/mediatek/mt8370-genio-510-evk.dts`
    ```git=!
    memory@40000000 {
                device_type = "memory";
              - reg = <0 0x40000000 0x1 0x00000000>;
              + reg = <0 0x40000000 0x0 0x80000000>; // 2G DDR
        };
    ```

### Kernel Configuration
- Please follow MTK Official [Kernel Change the Configuration](https://docs.yoctoproject.org/scarthgap/kernel-dev/common.html#changing-the-configuration) for loading `defconfig`

### Tools
- `lancfg.sh`: Ethernet MAC configuration, please place under `/usr/sbin/` in the rootfs
- `smarcCfg`: EEPROM tool, please place under `/usr/sbin/` in the rootfs

## Flash image
- [Set up environment]("https://mediatek.gitlab.io/aiot/doc/aiot-dev-guide/master/sw/yocto/get-started/env-setup/flash-env-linux.html#setup-tool-environment-linux")
- Flash demo image
    ```
    genio-flash -i rity-demo-image
    ```