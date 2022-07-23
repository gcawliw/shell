#/bin/bash
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

start_menu(){
clear
echo ""
red "     _           _"
blue "    (_) ___  ___| |__  _   _  __ _"
green "    | |/ _ \/ __| '_ \| | | |/ _\` |"
yellow "    | | (_) \__ \ | | | |_| | (_| |"
green "   _/ |\___/|___/_| |_|\__,_|\__,_|"
blue "  |__/"

red "             安装脚本集合"
echo ""
green "======================================="
red "0.部署linux基础环境"
red "1.安装ETCD（3节点集群）"
red "2.安装PGSQL (pgsql+patroni)"
red "3.安装barman"
blue "4.退出脚本"
green "======================================="
echo ""

read -p " 请输入数字 [0-4]:" num
case "$num" in
	0)
	install_base
	;;
	1)
	install_etcd
	;;
	2)
	install_pgsql
	;;
	3)
	install_barman
	;;
	4)
	exit 1
	;;
	*)
	clear
	echo "请输入正确数字 [1-4]"
	sleep 3s
	start_menu
	;;
esac
}

install_base() {
curl https://github.com/gcawliw/shell/raw/master/base.sh | bash
}

install_etcd() {
curl https://github.com/gcawliw/shell/raw/master/etcd.sh | bash
}

install_pgsql() {
curl https://github.com/gcawliw/shell/raw/master/pgsql.sh | bash
}

install_barman() {
curl https://github.com/gcawliw/shell/raw/master/barman.sh | bash
}

start_menu
