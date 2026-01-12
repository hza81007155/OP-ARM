#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
function merge_package(){
    repo=`echo $1 | rev | cut -d'/' -f 1 | rev`
    pkg=`echo $2 | rev | cut -d'/' -f 1 | rev`
    git clone --depth=1 --single-branch $1
    mv $2 package/custom/
    rm -rf $repo
}
function drop_package(){
    find package/ -follow -name $1 -not -path "package/custom/*" | xargs -rt rm -rf
}
function merge_feed(){
    if [ ! -d "feed/$1" ]; then
        echo >> feeds.conf.default
        echo "src-git $1 $2" >> feeds.conf.default
    fi
    ./scripts/feeds update $1
    ./scripts/feeds install -a -p $1
}
rm -rf package/custom; mkdir package/custom

# Modify default IP
sed -i 's/192.168.1.1/192.168.10.12/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.1.1/192.168.10.12/g' package/base-files/luci/bin/config_generate

# poweroff
git clone https://github.com/esirplayground/luci-app-poweroff package/luci-app-poweroff

#主题
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/kenzo/luci-app-argon-config
git clone -b 18.06 https://github.com/jerrykuku/luci-app-argon-config.git feeds/luci/applications/luci-app-argon-config

rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/kenzo/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon
sed -i '41,59d' feeds/luci/themes/luci-theme-argon/luasrc/view/themes/argon/footer.htm

# 微信推送
rm -rf feeds/kenzo/luci-app-wechatpush
rm -rf feeds/luci/applications/luci-app-serverchan
git clone -b openwrt-18.06 https://github.com/tty228/luci-app-serverchan.git feeds/luci/applications/luci-app-serverchan

# luci-app-adguardhome
rm -rf feeds/kenzo/luci-app-adguardhome
git clone https://github.com/Zane-E/luci-app-adguardhome.git feeds/kenzo/luci-app-adguardhome

# febrowser
rm -rf feeds/kenzo/luci-app-filebrowser
merge_package https://github.com/Lienol/openwrt-package openwrt-package/luci-app-filebrowser

# mosdns
rm -rf feeds/kenzo/luci-app-mosdns
rm -rf feeds/luci/applications/luci-app-mosdns
git clone -b v5-lua https://github.com/sbwml/luci-app-mosdns.git feeds/luci/applications/luci-app-mosdns

# 修改主题背景
cp -f $GITHUB_WORKSPACE/bg1.jpg feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# cpufreq
git clone --depth=1 --single-branch https://github.com/hza81007155/luci-app-cpufreq.git

# istoreos
git clone --depth=1 -b main https://github.com/linkease/nas-packages-luci package/nas-packages-luci
git clone --depth=1 -b master https://github.com/linkease/nas-packages package/nas-packages
git clone --depth=1 -b main https://github.com/linkease/istore package/istore

# 移除 openwrt feeds 自带的核心库
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
git clone https://github.com/xiaorouji/openwrt-passwall-packages package/passwall-packages

# 移除 openwrt feeds 过时的luci版本
rm -rf feeds/luci/applications/luci-app-passwall
git clone https://github.com/xiaorouji/openwrt-passwall package/passwall-luci

./scripts/feeds update -a
./scripts/feeds install -a
