# mongodb cluster
# 不启用验证。一仲裁节点，两节点集群部署。
helm install mongodb \
  center/bitnami/mongodb \
  -n dbs \
  --create-namespace \
  --set auth.enabled=false,architecture=replicaset

# mongodb express
# 作为临时管理的站点，服务端口8081
helm install mongodb-express \
  center/cowboysysop/mongo-express \
  -n dbs \
  --set mongodbServer=mongodb-0.mongodb-headless,mongodbEnableAdmin=true

# keycloak 单节点部署
cat <<EOF | helm install keycloak center/codecentric/keycloak -n keycloak --create-namespace --values -
extraEnv: |
  - name: KEYCLOAK_USER
    value: admin
  - name: KEYCLOAK_PASSWORD
    value: '!QAZ2wsx'
  - name: PROXY_ADDRESS_FORWARDING
    value: 'true'

replicas: 1
EOF

# 安装完后如果添加用户，不仅要执行sql添加，而且需要在pgpool的pod里执行
# pg_md5 -m --config-file="/opt/bitnami/pgpool/conf/pgpool.conf" -u "foo" "bar"
helm install postgresql center/bitnami/postgresql-ha -n dbs --create-namespace \
  --set global.postgresql.password=postgres,global.postgresql.repmgrPassword=repmgr,global.pgpool.adminPassword=admin

helm install pgadmin center/runix/pgadmin4 -n dbs --create-namespace