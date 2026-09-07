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
|       ├── nob-ptlf-m5sbc-2g.patch
|       └── nob-ptlf-m5sbc-4g.patch
|
├── tools/
│   ├── lancfg.sh
│   └── smarcCfg
|
├── edid/
│   └── PH800480T033-IBC06.bin
|
└── README.md
```
## Yocto BSP Configurations
- For packages installation, please add the following commands in the `$BUILD_DIR/conf/local.conf`
```
# Package installation
PACKAGE_CLASSES = "package_deb"
IMAGE_INSTALL:append = " glibc-utils localedef ntp nfs-utils dosfstools dos2unix net-tools"
IMAGE_INSTALL:append = " i2c-tools usbutils iperf3 rng-tools mtd-utils bluez5 can-utils pm-utils"
IMAGE_INSTALL:append = " lshw memtester gptfdisk rsync vim libmnl libmodbus networkmanager"
IMAGE_INSTALL:append = " sysbench stress-ng hdparm devmem2 matchbox-terminal python3-python-vlc"
IMAGE_INSTALL:append = " git doxygen libp11 dbus json-c json-glib cmocka jq"
IMAGE_INSTALL:append = " lame cups libvpx libssh libssh2 fmt libpcre leveldb tslib zlib lsb-release libusb1 libusbg"
IMAGE_INSTALL:append = " libgpiod libgpiod-dev libgpiod-tools dhcpcd wpa-suplicant mesa tzdata"
IMAGE_INSTALL:append = " gstreamer1.0-plugins-bad gstreamer1.0-plugins-good ttf-bitstream-vera tree"
IMAGE_INSTALL:append = " openldap openvpn qpdf tcpdump htop rfkill freetype cifs-utils v4l-utils mtools lmsensors"
IMAGE_INSTALL:append = " modemmanager minicom python3-speedtest-cli gcc gcc-symlinks g++"
IMAGE_INSTALL:append = " g++-symlinks make cmake automake libtool m4 autoconf-archive iproute2 procps autoconf"
IMAGE_INSTALL:append = " pulseaudio pulseaudio-module-dbus-protocol trace-cmd"
```
## U-boot Patch
- Please copy the `u-boot/nob-ptlf-m5sbc-Xg.patch` to `$BUILD_DIR/tmp/work/genio_510_evk-poky-linux/u-boot/git/git`
- Run patch apply
    ```shell=!
    e.g.
    # For error check (Won't patch)
    git apply --check nob-ptlf-m5sbc-2g.patch

    # if there is no error, patch file
    git apply nob-ptlf-m5sbc-2g.patch
    ```
- Re-build the u-boot
    ```shell=!
    bitbake u-boot -c compile -f && bitbake u-boot -c deploy -f
    ```
## Kernel Patch
- Please copy the `kernel/kernel-nob-ptlf-m5sbc-Xg.patch` to `$BUILD_DIR/tmp/work/genio_510_evk-poky-linux/linux-mtk/6.6.92/git`
- Run patch apply
    ```shell=!
    e.g.
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
## Panel Boot Up
### 5-inch RGB Panel
- Create directory in rootfs at `/lib/firmware/edid` & place the EDID `PH800480T033-IBC06.bin`
    ```
    mkdir -p /lib/firmware/edid
    cp PH800480T033-IBC06.bin /lib/firmware/edid/
    ```
- Check kernel configuration enable ? Should output `CONFIG_DRM_LOAD_EDID_FIRMWARE=y`
    ```
    zcat /proc/config.gz | grep -i DRM_LOAD_EDID
    ```
- Reboot and modify u-boot environment
    ```
    u-boot=> setenv bootargs drm.edid_firmware=HDMI-A-1:edid/PH800480T033-IBC06.bin video=HDMI-A-1:e
    u-boot=> saveenv
    u-boot=> reset
    ```