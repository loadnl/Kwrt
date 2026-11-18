#!/bin/bash

shopt -s extglob

SHELL_FOLDER=$(dirname $(readlink -f "$0"))

rm -rf package/boot package/firmware/ipq-wifi target/linux/generic target/linux/qualcommax package/firmware/ath11k-firmware package/kernel/mac80211 package/kernel/nat46

git_clone_path 25.12-nss https://github.com/LiBwrt/openwrt-6.x target/linux/generic target/linux/qualcommax package/boot package/firmware/ipq-wifi package/firmware/ath11k-firmware package/kernel/mac80211 package/kernel/nat46

wget -N https://github.com/LiBwrt/LibWrt/raw/refs/heads/25.12-nss/include/image-commands.mk -P include/
wget -N https://github.com/LiBwrt/LibWrt/raw/refs/heads/25.12-nss/config/Config-ipq.in -P config/
wget -N https://github.com/LiBwrt/LibWrt/raw/refs/heads/25.12-nss/Config.in -P ./

rm -rf feeds/kiddin9/shortcut-fe 

git clone https://github.com/laipeng668/nss-packages.git -b NSS-LibWrt package/nss-packages
git clone https://github.com/qosmio/sqm-scripts-nss.git package/sqm-scripts-nss

sed -i "/ECM_INTERFACE_RAWIP_ENABLE/d"  package/nss-packages/qca-nss-ecm/Makefile
rm -rf package/nss-packages/nss-userspace-oss

sed -i "s/luci uboot-envtools wpad-openssl/luci uboot-envtools wpad-mbedtls/" target/linux/qualcommax/Makefile

# ===== Open-Box: 对齐上游 liandu2024/Open-Box 的最新 release =====
# kiddin9/op-packages 内置的 luci-app-open-box 版本会落后上游 release, 这里在编译前查询最新 tag,
# 预先下载对应架构的完整包到 dl/ 并校验压缩包内部结构; 任何一步不符合预期就保留 feed 原版本, 不阻断构建。
OB_PKG="package/feeds/kiddin9/luci-app-open-box"
if [ -f "$OB_PKG/Makefile" ]; then
	OB_CUR="$(sed -n 's/^PKG_VERSION:=//p' "$OB_PKG/Makefile" | head -n 1)"
	OB_TAG="$(curl -s -H "Authorization: token $REPO_TOKEN" \
		https://api.github.com/repos/liandu2024/Open-Box/releases/latest | jq -r '.tag_name // empty')"
	OB_VER="${OB_TAG#v}"
	echo "Open-Box: feed=${OB_CUR:-unknown} upstream=${OB_VER:-unknown}"
	if [ -n "$OB_VER" ] && [ "$OB_CUR" != "$OB_VER" ]; then
		OB_TARBALL="open-box-linux-arm64.tar.gz"
		mkdir -p dl
		if curl -fSL --retry 3 -o "dl/$OB_TARBALL" \
			"https://github.com/liandu2024/Open-Box/releases/download/$OB_TAG/$OB_TARBALL"; then
			if tar -tzf "dl/$OB_TARBALL" 2>/dev/null | grep -q 'openwrt/initd/openbox'; then
				sed -i -e "s/^PKG_VERSION:=.*/PKG_VERSION:=$OB_VER/" -e "s/^PKG_RELEASE:=.*/PKG_RELEASE:=1/" "$OB_PKG/Makefile"
				echo "Open-Box: 已升级到 $OB_VER"
			else
				echo "Open-Box: $OB_VER 压缩包结构不匹配, 回退 feed 版本 $OB_CUR"
				rm -f "dl/$OB_TARBALL"
			fi
		else
			echo "Open-Box: $OB_VER 下载失败, 回退 feed 版本 $OB_CUR"
		fi
	fi
fi
