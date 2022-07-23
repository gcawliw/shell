#!/bin/bash
install_pgsql() {
echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" | tee /etc/apt/sources.list.d/pgsql13.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt update && apt -y install postgresql-13
systemctl disable postgresql
systemctl stop postgresql
###

###install Patroni
install_patroni() {
apt -y install python3-pip python3-setuptools python3-dev python3-wheel gcc libpq-dev python3-psycopg2
pip3 install patroni[etcd3]

cat > /etc/patroni/patroni.yml << EOF
scope: pg
namespace: /service/
name: postgresql01

restapi:
    listen: 127.0.0.1:8008
    connect_address: 127.0.0.1:8008

etcd3:
    host: :2379
    host: :2379
    host: :2379

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
    listen: 127.0.0.1:5432
    connect_address: 127.0.0.1:5432
    data_dir: /db/pgsql/data
    bin_dir: /usr/lib/postgresql/10/bin
    pgpass: /tmp/pgpass01
    authentication:
        replication:
            username: replicator
            password: 
        superuser:
            username: postgres
            password: 
   parameters:
        unix_socket_directories: '.'

tags:
    nofailover: false
    noloadbalance: false
    clonefrom: false
EOF
}

