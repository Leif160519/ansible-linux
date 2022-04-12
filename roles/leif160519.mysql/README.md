## Ansible Role:MySql
安装二进制mysql-5.7.28

## 系统要求
- Debian(全系列)
- RedHat(全系列)

## 用法
```
vars:
  mysql_root_dir: /var/lib/mysql
  mysql_config_file: /etc/my.cnf
  mysql_log_dir: /var/log/mysql
  mysql_run_dir: /var/run/mysql
  mysql_pre_dir: /usr/share/mysql
roles:
  - role: roles/leif160519.mysql
```

| var | value                                             |
|-----|---------------------------------------------------|
| mysql_root_dir    | mysql根目录                         |
| mysql_config_file | mysql配置文件目录                   |
| mysql_log_dir     | mysql日志目录                       |
| mysql_run_dir     | mysql sock和pid文件存放目录         |
| mysql_pre_dir     | mysql服务启动前预先执行的脚本目录   |

## 补充
若想安装mysql 8.0版本，直接修改`vars/main.yml`中的如下内容
```
mysql_version: mysql-8.0.28-linux-glibc2.12-x86_64
mysql_url: https://cdn.mysql.com//Downloads/MySQL-8.0/{{ mysql_version }}.tar.xz
```
