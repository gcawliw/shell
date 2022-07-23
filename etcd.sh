#/bin/bash
install_etcd() {
mkdir -p /db/
mkdir -p /etc/etcd
cd /db/
sudo groupadd -r etcd
sudo useradd -r -g etcd -d /db/etcd/ -s /bin/false etcd

#etcd_ver="$(wget --no-check-certificate -qO- https://api.github.com/repos/etcd-io/etcd/releases | grep "tag_name" | head -1 | awk -F '": "' '{print $2}' |cut -d\" -f1)"
#wget https://github.com/etcd-io/etcd/releases/download/${etcd_ver}/etcd-${etcd_ver}-linux-amd64.tar.gz
#tar -zvxf etcd-${etcd_ver}-linux-amd64.tar.gz && rm -f etcd-${etcd_ver}-linux-amd64.tar.gz
#mv etcd-${etcd_ver}-linux-amd64/ etcd/

wget https://github.com/etcd-io/etcd/releases/download/v3.5.4/etcd-v3.5.4-linux-amd64.tar.gz
tar -zvxf etcd-v3.5.4-linux-amd64.tar.gz && rm -f etcd-v3.5.4-linux-amd64.tar.gz
mv etcd-v3.5.4-linux-amd64/ etcd/

chown -R etcd /db/etcd
cp /db/etcd/etcd /usr/bin
cp /db/etcd/etcdctl /usr/bin

###
read -p "请输入本ETCD节点序号（1-3）:" etcd_node
read -p "请输入ETCD1节点的IP地址:" etcd1_ip
read -p "请输入ETCD2节点的IP地址:" etcd2_ip
read -p "请输入ETCD3节点的IP地址:" etcd3_ip
###
if [ ${etcd_node} == 1 ];then
etcd_host=${etcd1_ip}
elif [ ${etcd_node} == 2 ];then
etcd_host=${etcd2_ip}
elif [ ${etcd_node} == 3 ];then
etcd_host=${etcd3_ip}
else
echo "节点序号错误"
exit
fi

cat > /etc/etcd/etcd.yml << EOF
name: etcd.cluster.node0${etcd_node}
initial-advertise-peer-urls: http://${etcd_host}:2380
data-dir: /db/etcd/etcd.cluster.node01
listen-peer-urls: http://${etcd_host}:2380
listen-client-urls: http://${etcd_host}:2379,http://127.0.0.1:2379
advertise-client-urls: http://${etcd_host}:2379
initial-cluster-token: etcd.cluster
initial-cluster: etcd.cluster.node01=http://${etcd1_ip}:2380,etcd.cluster.node02=http://${etcd2_ip}:2380,etcd.cluster.node03=http://${etcd3_ip}:2380
auto-compaction-retention: '1'
quota-backend-bytes: 8589934592
initial-cluster-state: new
EOF

cat > /lib/systemd/system/etcd.service << EOF
[Unit]
Description=Etcd Server
After=network.target

[Service]
Type=notify
WorkingDirectory=/db/etcd/
User=etcd
ExecStart=/db/etcd/etcd --config-file /etc/etcd/etcd.yml

Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable etcd.service
#systemctl start etcd.service
#/db/etcd/etcdctl endpoint status --cluster --write-out=table
echo "ETCD配置文件：/etc/etcd/etcd.yml"
echo "ETCD根目录：/db/etcd/"
echo "ETCD监听地址：${etcd_host}:2379"
}

install_etcd
