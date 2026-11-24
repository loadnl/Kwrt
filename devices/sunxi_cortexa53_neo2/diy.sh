#!/bin/bash
# NanoPi NEO2 (sunxi / cortexa53) 定制
# 与 devices/sunxi_cortexa53/diy.sh 的差别: 只针对 H5 单机型, 不碰 A64/H6 相关的东西

shopt -s extglob

SHELL_FOLDER=$(dirname $(readlink -f "$0"))

# 性能优先: sunxi 上游一直用 -Os 压体积, NEO2 跑在 SD 卡上, 体积优势换不来观感
sed -i 's/Os/O2/g' include/target.mk

# 该 target 的默认包: SD 卡分区/挂载工具 + USB 网卡驱动 (NEO2 只有一个原生千兆口)
sed -i 's/DEFAULT_PACKAGES +=/DEFAULT_PACKAGES += fdisk lsblk kmod-usb-net-asix-ax88179 kmod-usb-net-rtl8152/' target/linux/sunxi/Makefile
