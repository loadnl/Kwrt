#### 固件下载与在线定制: [openwrt.ai](https://openwrt.ai)

### openwrt 软路由固件

#### 基于官方openwrt-25.12最新稳定分支, 并基于国内使用喜欢做大量优化

#### 原生极致纯净, 固件默认只包含基础上网功能, 后台在线选装插件, 或在线定制包含指定插件的固件

#### 自建在线插件仓库 [dl.openwrt.ai](https://dl.openwrt.ai), 额外收录三方插件1000+, 插件库日更

##### TG群: [Kwrt交流群](https://t.me/opkwrt)

<img src="assets/p1.png" alt="" width="800">

<img src="assets/p2.png" alt="" width="800">

<img src="assets/p3.png" alt="" width="800">

<img src="assets/p4.png" alt="" width="800">

<img src="assets/p5.png" alt="" width="800">


## Acknowledgments

- [OpenWrt](https://github.com/openwrt/openwrt)
- [Lean's OpenWrt](https://github.com/coolsnowwolf/lede)
- [ImmortalWrt](https://github.com/immortalwrt/immortalwrt)
- [iStoreOS](https://github.com/istoreos)
- [unifreq](https://github.com/unifreq/openwrt_packit)
- [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt)
- [hanwckf](https://github.com/hanwckf/immortalwrt-mt798x)
- [aparcar](https://github.com/openwrt/asu)
- [GitHub](https://github.com)
- [GitHub Actions](https://github.com/features/actions)



---

## 本 fork 的定制说明 (loadnl/Kwrt)

基于 [kiddin9/Kwrt](https://github.com/kiddin9/Kwrt) `25.12` 分支，目前维护两个目标：

| 目标目录 | 设备 | 平台 | 说明 |
| --- | --- | --- | --- |
| `qualcommax_ipq60xx` | Redmi AX5 JDCloud | `qualcommax/ipq60xx` | 老目标，rootfs 只有 113 MB |
| `sunxi_cortexa53_neo2` | FriendlyARM NanoPi NEO2 | `sunxi/cortexa53`（H5 / aarch64） | 新增，SD 卡 ext4，可装 Open-Box |

### 怎么编译

1. 打开仓库的 **Actions** → 左侧 **Build OpenWrt** → 右侧 **Run workflow**
2. `target` 下拉选设备：`qualcommax_ipq60xx`（AX5 JDCloud）或 `sunxi_cortexa53_neo2`（NanoPi NEO2）
3. `action` 留空；需要忽略编译缓存时填 `nocache`
4. 单次构建约 100–150 分钟

产物位置：

- **Releases**：`Kwrt <日期> <target>`，附件为固件（`.bin` / `.itb` / `.img.gz`）+ `sha256sums` + `.config`
- **Actions → 运行记录 → Artifacts**：完整 `bin/targets` 目录

### NanoPi NEO2 这个目标做了什么

`devices/sunxi_cortexa53_neo2/`：

- **只编一个设备**：`friendlyarm_nanopi-neo2`，不再连带 A64/H6 那堆机型，构建时间短很多
- **ext4 sdcard 镜像**（`CONFIG_TARGET_ROOTFS_EXT4FS=y`）：sunxi 的 sdcard 镜像只有 boot + rootfs 两个分区，选 squashfs 就没有可写的 overlay；ext4 还能事后 `resize2fs` 扩容，正好放 Open-Box
- **rootfs 分区 1004 MB**：Open-Box 装完连数据一共要 256 MB 以上
- **内置 Open-Box 运行依赖**：`kmod-tun`、`kmod-nft-queue`、`kmod-nft-nat`、`kmod-veth`、`ip-full`、`ca-bundle`（另有 `kmod-nft-tproxy`、`kmod-inet-diag`、`kmod-netlink-diag`）
- **SD 卡 / USB 工具**：`block-mount`、`fdisk`、`lsblk`、`kmod-usb-storage`、`kmod-fs-ext4`/`vfat`/`exfat`
- **USB 网卡驱动**：`kmod-usb-net-asix-ax88179`、`kmod-usb-net-rtl8152`（NEO2 只有一个原生千兆口）
- **性能优先**：`diy.sh` 里把 `-Os` 换成 `-O2`（沿用上游 sunxi 的做法）

刷机：解压 `kwrt-sunxi-cortexa53-friendlyarm_nanopi-neo2-ext4-sdcard.img.gz`，用 balenaEtcher / Rufus 写到 SD 卡。默认地址 `10.0.0.1`，`root` 无密码。

### Open-Box 为什么没直接打进镜像

Open-Box（[liandu2024/Open-Box](https://github.com/liandu2024/Open-Box)）的路由器端是**闭源专有软件**，许可证明确禁止再分发，所以固件里只预置它缺的依赖，本体由官方安装脚本在线拉取（约 50 MB）：

```sh
# NEO2 固件里已经预置了这个封装脚本
openbox-install                     # 默认面板端口 3036，直连失败自动切镜像
openbox-install --port 3080         # 指定面板端口
openbox-install --mirror            # 直接走 gh-proxy 镜像
```

它也等价于手敲官方的：

```sh
curl -fsSL https://raw.githubusercontent.com/liandu2024/Open-Box/main/scripts/install.sh | sh
```

AX5 JDCloud 那个目标则**不建议**装 Open-Box：rootfs 只有 113 MB，装不下；要装只能放到 eMMC 数据分区（`/opt/open-box` → `/mnt/mmcblk0p25/open-box`），所以那边只编了 `kmod-nft-queue`、`kmod-veth` 两个模块。

### 定制内容

| 文件 | 说明 |
| --- | --- |
| `.github/workflows/Openwrt-AutoBuild.yml` | `workflow_dispatch` 手动触发，目标改成下拉选择；只用内置 `GITHUB_TOKEN`，不需要 secret；配置自检改成按目标读 `config-check.txt`；Release 附件补上 `.img` / `.img.gz`；Release 说明按目标的 `release-note.txt` 生成 |
| `.github/workflows/Rebuild-From-Imagebuilder.yml` | 用已有 imagebuilder 快速重出镜像；包清单改成 `packages_file` 输入，附件补 `.img.gz` |
| `devices/qualcommax_ipq60xx/` | 只编 `redmi_ax5-jdcloud`；编入 `kmod-nft-queue`、`kmod-veth`、`kmod-tun`、`kmod-nft-nat`、`ip-full`；`config-check.txt` 为自检清单 |
| `devices/sunxi_cortexa53_neo2/` | 只编 `friendlyarm_nanopi-neo2`；ext4 sdcard；Open-Box 依赖；`diy/files/usr/sbin/openbox-install` 一键装 Open-Box |
| `devices/common/diy.sh` | 上游包仓库 CI 等待改为最多 10 分钟，避免构建卡死 |

### 加新机型

1. 复制 `devices/<已有目标>/` 成 `devices/<board>_<subtarget>_<机型>/`
2. 改 `.config` 里的 `CONFIG_TARGET_*` 与 `CONFIG_TARGET_DEVICE_*`（名字必须和 `devices/` 下的目录名一致）
3. 在该目录写 `config-check.txt`（自检清单）和可选 `release-note.txt`（Release 说明）
4. 需要内核/包层面改动时在 `diy.sh` 里做，需要往 rootfs 塞文件时放 `diy/files/`
5. 把目录名加进 `.github/workflows/Openwrt-AutoBuild.yml` 里 `target` 的 `options`

### 同步上游

上游默认分支会持续更新（`25.12`）。同步时把 `devices/common`、`.github/workflows` 与本 fork 的定制改动合并即可，注意保留上面表格里的定制。
