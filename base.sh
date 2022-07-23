#!/bin/bash
blue(){
    echo -e "\033[34m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}
bred(){
    echo -e "\033[31m\033[01m\033[05m$1\033[0m"
}
byellow(){
    echo -e "\033[33m\033[01m\033[05m$1\033[0m"
}


red "     _           _"
blue "    (_) ___  ___| |__  _   _  __ _"
green "    | |/ _ \/ __| '_ \| | | |/ _\` |"
yellow "    | | (_) \__ \ | | | |_| | (_| |"
green "   _/ |\___/|___/_| |_|\__,_|\__,_|"
blue "  |__/"

###设置语言环境
local_language() {
    local lang=""
    apt update & apt -y install language-pack-zh-han*
    lang=`locale -a | grep "zh_CN."`

    cat > /etc/default/locale << EOF
LANG="${lang}"
LANGUAGE=
LC_ALL="${lang}"
EOF
 
    source /etc/default/locale
        
    if [  "$(locale | grep ${lang})" ];then
           green "set local_language ok"
    else
           red "set local_language failed"
    fi
}
###


###修改时区
local_timezone() {
    rm -f /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

    if [ "$(date | grep "CST")" ];then
        	 green "set local_timezone ok"
    else
           red "set local_timezone failed"
    fi
}
###

###设置文件打开数量和socker限制
local_ulimit() {
    cat > /etc/security/limits.conf << EOF
* soft nofile 65535
* hard nofile 65535
serviceone soft nofile 65535
serviceone hard nofile 65535
EOF

    cat > /etc/systemd/user.conf << EOF
[Manager]
DefaultLimitNOFILE=65535
EOF

    cat > /etc/systemd/system.conf << EOF
[Manager]
DefaultLimitNOFILE=65535
EOF


    cat >> /etc/sysctl.conf << EOF
net.ipv4.ip_local_port_range=15000 61000
net.ipv4.tcp_fin_timeout=30
EOF

    sysctl -p
}

local_language
local_timezone
local_ulimit
###安装htop和nmon
apt -y install htop nmon
###
