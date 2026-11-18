#!/usr/bin/env python3
"""
修补 imagebuilder 版 include/rootfs.mk 的一个上游 bug。

OpenWrt 的 rootfs.mk 里有这么一段:

    if [ -z "$(CONFIG_USE_APK)" ]; then \
        $(if $(IB),,awk -i inplace ...) ; \
        $(if $(SOURCE_DATE_EPOCH),sed -i "s/Installed-Time: ...") \
    fi; \

在 imagebuilder 模式下 IB 非空, 第一个 $(if $(IB),,...) 展开成空,
生成的 shell 命令就变成:

    if [ -z "" ]; then  ; sed -i ...

bash 报 "syntax error near unexpected token `;'", prepare_rootfs 直接失败。

把条件改成恒为空 ($(if ,,awk ...)), 就会走 else 分支正常执行 awk。
awk -i inplace 需要 gawk (工作流里已安装并设为默认)。

用法: python3 fix-ib-rootfs.py <imagebuilder 目录>/include/rootfs.mk
"""

import sys

OLD = "$(if $(IB),,awk -i inplace"
NEW = "$(if ,,awk -i inplace"


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: fix-ib-rootfs.py <path/to/include/rootfs.mk>")
        return 2

    path = sys.argv[1]
    with open(path, encoding="utf-8") as f:
        text = f.read()

    if OLD not in text:
        if NEW in text:
            print("already patched: %s" % path)
            return 0
        print("WARNING: pattern not found, left untouched: %s" % path)
        return 0

    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text.replace(OLD, NEW))

    print("patched %s" % path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
