#!/bin/bash
install_pgsql() {
echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" | tee /etc/apt/sources.list.d/pgsql13.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt update && apt -y install postgresql-13
systemctl disable postgresql
systemctl stop postgresql
}
###

###install Patroni
install_patroni() {
apt -y install python3-pip python3-setuptools python3-dev python3-wheel gcc libpq-dev python3-psycopg2
pip3 install patroni[etcd3]
mkdir /etc/patroni/
mkdir -p /db/pgsql/data
chown -R postgres /db/pgsql

read -p "请输入PGSQL节点名称(集群中不可重复):" pgsq_name
read -p "请输入PGSQL监听地址（本机IP）:" pgsql_host
read -p "请输入PGSQL数据库postgres用户密码:" postgres_PW
read -p "请输入PGSQL数据库replicator用户密码:" replicator_PW
read -p "请输入ETCD1节点的IP地址:" etcd1_ip
read -p "请输入ETCD2节点的IP地址:" etcd2_ip
read -p "请输入ETCD3节点的IP地址:" etcd3_ip



cat > /etc/patroni/patroni.yml << EOF
scope: pg
namespace: /service/
name: ${pgsq_name}

restapi:
    listen: ${pgsql_host}:8008
    connect_address: ${pgsql_host}:8008

etcd3:
    host: ${etcd1_ip}:2379
    host: ${etcd2_ip}:2379
    host: ${etcd3_ip}:2379

bootstrap:
    dcs:
        ttl: 30
        loop_wait: 10
        retry_timeout: 10
        maximum_lag_on_failover: 1048576
        postgresql:
            use_pg_rewind: true

    initdb:
    - encoding: UTF8
    - data-checksums

    pg_hba:
    - host replication replicator 0.0.0.0/0 md5
    - host all all 0.0.0.0/0 md5

    users:
        admin:
            password: admin
            options:
                - createrole
                - createdb

postgresql:
    listen: ${pgsql_host}:5432
    connect_address: ${pgsql_host}:5432
    data_dir: /db/pgsql/data
    bin_dir: /usr/lib/postgresql/13/bin
    pgpass: /tmp/pgpass01
    authentication:
        replication:
            username: replicator
            password: ${replicator_PW}
        superuser:
            username: postgres
            password: ${postgres_PW}
   parameters:
        unix_socket_directories: '.'

tags:
    nofailover: false
    noloadbalance: false
    clonefrom: false
EOF



cat > /lib/systemd/system/patroni.service << EOF
[Unit]
Description=Runners to orchestrate a high-availability PostgreSQL
After=syslog.target network.target

[Service]
Type=simple

User=postgres
Group=postgres

# StandardOutput=syslog
ExecStart=/usr/local/bin/patroni /etc/patroni/patroni.yml
KillMode=process
TimeoutSec=30
Restart=no

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable patroni.service
}

install_pgsql
install_patroni
