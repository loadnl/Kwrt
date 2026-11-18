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

基于 [kiddin9/Kwrt](https://github.com/kiddin9/Kwrt) `25.12` 分支，定向用于 **Redmi AX5 JDCloud**（`qualcommax/ipq60xx`，设备 `redmi_ax5-jdcloud`），并内置互联网插件 **Open-Box**（`luci-app-open-box`）。

### 怎么编译

1. 打开仓库的 **Actions** → 左侧 **Build OpenWrt** → 右侧 **Run workflow**
2. `target` 保持默认 `qualcommax_ipq60xx` 即可（也可填 `devices/` 下的其它目录名）
3. `action` 留空；需要忽略编译缓存时填 `nocache`
4. 单次构建约 100–150 分钟

产物位置：

- **Releases**：`Kwrt <日期> qualcommax_ipq60xx (Open-Box)`，附件为 `.bin` 固件 + `sha256sums`
- **Actions → 运行记录 → Artifacts**：完整 `bin/targets` 目录

### 定制内容

| 文件 | 说明 |
| --- | --- |
| `.github/workflows/Openwrt-AutoBuild.yml` | 改为 `workflow_dispatch` 手动触发；只用内置 `GITHUB_TOKEN`，无需配置任何 secret；新增配置校验步骤 |
| `devices/qualcommax_ipq60xx/.config` | 只编译 `redmi_ax5-jdcloud` 单个设备；打开 `luci-app-open-box` 及其依赖 |
| `devices/qualcommax_ipq60xx/settings.ini` | 固件同时上传 artifact 与 release |
| `devices/common/diy.sh` | 上游包仓库 CI 等待改为最多 10 分钟，避免构建卡死 |

### 同步上游

上游默认分支会持续更新（`25.12`）。同步时把 `devices/common`、`.github/workflows` 与本 fork 的定制改动合并即可，注意保留上面表格里的三处定制。
