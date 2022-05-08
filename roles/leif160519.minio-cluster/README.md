# 使用ansible安装minio集群
docker 部署minio: [leif160519/docker-script/minio][7]

## 1.前提条件
- 准备四个节点服务器，配置一样，时区和系统时间保持一致
- 每个节点服务器准备四块大小一样的挂载点，挂载路径分别为`/mnt/disk1`到`/mnt/disk4`,当然，每台服务器只有一块硬盘也可以

## 2.用法
|     var                |                value                              |
|------------------------|---------------------------------------------------|
| minio_root_user        |  minio的root用户名                                |
| minio_root_password    |  minio的root用户密码                              |
| minio_identity_ldap    |  是否开启ldap身份验证，on表示开启，off表示关闭    |
| ldap_server            |  ldap服务器地址                                   |
| ldap_bind_dn           |  查询ldap服务器的专有名称                         |
| ldap_bind_dn_password  |  查询ldap服务器的密码                             |
| ldap_base_dn           |  查询ldap服务器身份验证的基本专有名称             |
| minio_job_name         |  抓取minio指标的prometheus job名称                |
| minio_cache_drives     |  挂载的缓存驱动器或目录列表，逗号分隔             |
| minio_cache_exclude    |  缓存排除文件列表，逗号分隔                       |

## 3.docker版本参考
- [minio-linux][1]

## 4.config.env参数解析

- [environment-variables][2]
- [active-directory-ldap-identity-management][3]
- [metrics-and-logging][4]
- [minio-disk-cache-guide][5]
- [Disk Caching Design][6]


| 变量名称 | 说明 |
|----------|------|
| MINIO_SERVER_URL | 指定minio控制台用于连接到minio服务器的url |
| MINIO_BROWSER_REDIRECT_URL | 指定minio控制台提供的对外访问的重定向url |
| MINIO_ROOT_USER | root用户的用户名 |
| MINIO_ROOT_PASSWORD | root用户的访问密钥|
| MINIO_IDENTITY_LDAP_SERVER_ADDR | 指定 Active Directory/LDAP 服务器的主机名 |
| MINIO_IDENTITY_LDAP_STS_EXPIRY | 设定会话过期时间 |
| MINIO_IDENTITY_LDAP_SERVER_STARTTLS | 指定on启用 到 AD/LDAP 服务器的StartTLS连接 |
| MINIO_IDENTITY_LDAP_SERVER_INSECURE | 指定on以允许与 AD/LDAP 服务器的不安全（非 TLS 加密）连接 |
| MINIO_IDENTITY_LDAP_LOOKUP_BIND_DN | 指定 MinIO 在查询 AD/LDAP 服务器时使用的 AD/LDAP 帐户的专有名称 (DN) |
| MINIO_IDENTITY_LDAP_LOOKUP_BIND_PASSWORD | 指定Lookup-Bind用户帐户的密码 |
| MINIO_IDENTITY_LDAP_USER_DN_SEARCH_FILTER | 指定在查询与身份验证客户端提供的用户凭据匹配的用户凭据时 MinIO 使用的 AD/LDAP 搜索过滤器 |
| MINIO_IDENTITY_LDAP_USER_DN_SEARCH_BASE_DN | 指定 MinIO 在查询与身份验证客户端提供的凭据匹配的用户凭据时使用的基本专有名称 (DN) |
| MINIO_IDENTITY_LDAP_GROUP_SEARCH_FILTER | 指定 AD/LDAP 搜索过滤器以对经过身份验证的用户执行组查找 |
| MINIO_IDENTITY_LDAP_GROUP_SEARCH_BASE_DN | 指定 MinIO 在执行组查找时使用的组搜索基础专有名称 |
| MINIO_PROMETHEUS_AUTH_TYPE | 指定 Prometheus抓取端点的身份验证模式 ||
| MINIO_PROMETHEUS_URL | 为抓取minio指标的prometheus服务的url ||
| MINIO_PROMETHEUS_JOB_ID | 指定抓取minio指标的自定义prometheus的job ID ||
| MINIO_CACHE | 设置为“on”或“off”开启或关闭缓存 |
| MINIO_CACHE_DRIVES | 挂载的缓存驱动器或目录列表，以“,”分隔 |
| MINIO_CACHE_EXPIRY | 缓存过期时间 |
| MINIO_CACHE_QUOTA | 缓存的最大允许使用百分比 (0-100) |
| MINIO_CACHE_EXCLUDE | 以“,”分隔的缓存排除模式列表 |
| MINIO_CACHE_AFTER | 缓存对象前的最小访问次数 |
| MINIO_CACHE_COMMENT | 设置为 'writeback' 或 'writethrough' 用于上传缓存 |
| MINIO_CACHE_RANGE | 设置为“on”或“off”缓存每个对象的独立范围请求，默认为“on” |
| MINIO_CACHE_WATERMARK_LOW | 缓存驱逐停止的缓存配额百分比 |
| MINIO_CACHE_WATERMARK_HIGH | 缓存驱逐开始时的缓存配额百分比 |


[1]: https://github.com/leif160519/minio-linux
[2]: https://docs.min.io/minio/baremetal/reference/minio-server/minio-server.html#environment-variables
[3]: https://docs.min.io/minio/baremetal/reference/minio-server/minio-server.html#active-directory-ldap-identity-management
[4]: https://docs.min.io/minio/baremetal/reference/minio-server/minio-server.html#metrics-and-logging
[5]: https://docs.min.io/docs/minio-disk-cache-guide.html
[6]: https://github.com/minio/minio/blob/master/docs/disk-caching/DESIGN.md
[7]: https://github.com/Leif160519/docker-script/tree/master/minio
