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

## 主从复制安装方法
1.准备两台已经安装好mysql 8.0的服务器
2.主库配置
```
vim /etc/my.cnf
[mysqld]
# 主从复制
log-bin=mysql-bin #开启二进制日志
server-id=100 #设置server-id 必须唯一,建议为ip后三位
```
配置后重启myql

3.获取当前主数据库中binlog节点
```
mysql> show master status;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000001 |      820 |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)
```

4.从库配置
```
vim /etc/my.cnf
[mysqld]
server-id=101 #设置server-id 必须唯一,建议为ip后三位
```

5.在从库中添加主数据库信息
```

-- 添加主数据库信息及读取binlog的节点信息
CHANGE MASTER TO MASTER_HOST = '192.168.158.128',
MASTER_USER = 'root',
MASTER_PASSWORD = 'password',
MASTER_LOG_FILE = 'mysql-bin.000001',
MASTER_LOG_POS = 820;
-- 启动从库
START SLAVE;
-- 查看主从状态
SHOW SLAVE STATUS\G;
```

查看主从同步状态，如果Slave_IO_Running = yes并且Slave_SQL_Running = yes则代表主从同步已经正常启动，若存在No，则需要根据Last_IO_Error 、Last_SQL_Error、Last_Error这三个字段对应的报错信息进行分析及修改。

```
mysql> show slave status\G;
*************************** 1. row ***************************
               Slave_IO_State: Waiting for source to send event
                  Master_Host: 192.168.0.35
                  Master_User: root
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000001
          Read_Master_Log_Pos: 1463
               Relay_Log_File: ecm-mzl84-relay-bin.000002
                Relay_Log_Pos: 1632
        Relay_Master_Log_File: mysql-bin.000001
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 1463
              Relay_Log_Space: 1846
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 35
                  Master_UUID: 998ff74e-ceda-11ec-b6f3-fa163eac20b9
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Replica has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 
            Executed_Gtid_Set: 
                Auto_Position: 0
         Replicate_Rewrite_DB: 
                 Channel_Name: 
           Master_TLS_Version: 
       Master_public_key_path: 
        Get_master_public_key: 0
            Network_Namespace: 
1 row in set, 1 warning (0.00 sec)

ERROR: 
No query specified
```

6.验证
在主库中创建一个数据库或者修改用户密码，在从库中看是否同步过来

7.注意
主从结构搭建完成之后，切勿在从库中进行数据写入操作，否则会破坏数据库的同步状态
```
Slave_SQL_Running: NO
```

解决办法:从库执行命令
```
stop slave；#先停掉slave
set global sql_slave_skip_counter=1;  #跳过错误步数，后面步数可变
start slave； #在启动slave
show slave status\G；#查看同步状态
```

## 参考
- [MySQL8.0主从复制][1]
- [MySQL-----主从复制 Slave_SQL_Running:no][2]

[1]: https://blog.csdn.net/weixin_45170351/article/details/122643695
[2]: https://blog.csdn.net/jmwn99/article/details/122800962
