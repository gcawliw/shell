#/bin/bash
install_etcd() {
mkdir -p /db/
mkdir -p /etc/etcd
cd /db/
useradd -d /home/etcd -s /bin/bash etcd

etcd_ver="$(wget --no-check-certificate -qO- https://api.github.com/repos/etcd-io/etcd/releases | grep "tag_name" | head -1 | awk -F '": "' '{print $2}' |cut -d\" -f1)"
wget https://github.com/etcd-io/etcd/releases/download/${etcd_ver}/etcd-${etcd_ver}-linux-amd64.tar.gz
tar -zvxf etcd-${etcd_ver}-linux-amd64.tar.gz && rm -f etcd-${etcd_ver}-linux-amd64.tar.gz
mv etcd-${etcd_ver}-linux-amd64/ etcd/
chown -R etcd /db/etcd

read -p "请输入ETCD监听地址:" etcd_host

cat > /etc/etcd/etcd.yml << EOF
name: etcd.cluster.node01
initial-advertise-peer-urls: http://${etcd_host}:2380
data-dir: /db/etcd/etcd.cluster.node01
listen-peer-urls: http://${etcd_host}:2380
listen-client-urls: http://${etcd_host}:2379,http://127.0.0.1:2379
advertise-client-urls: http://${etcd_host}:2379
initial-cluster-token: etcd.cluster
initial-cluster: etcd.cluster.node01=http://${etcd_host}:2380
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
