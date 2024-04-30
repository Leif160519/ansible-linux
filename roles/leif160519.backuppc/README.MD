## 使用ansible管理backuppc备份
项目改造于[HanXHX/ansible-backuppc][1]

## 注意
- 资产名称必须为小写
- backuppc的安装详见：[backuppc][2]
- 执行ansible之前，需将backuppc服务器上的backuppc用户公钥提前复制到目标服务器中


## 其他
若备份的路径中是非`/`下的挂载路径，则backuppc会默认不备份，需要修改rsync参数：
打开backuppc首页=左手边选择“修改服务器配置”-切换到“传输”选项卡-在`RsyncArgs`选项中删除`--one-file-system`参数-点击”保存“

官方文档解释：http:<backuppc-server>:<backuppc-port>/BackupPC_Admin?action=view&type=docs#_conf_rsyncsharename_
```
$Conf{RsyncShareName} = '/';
Share name to backup. For $Conf{XferMethod} = "rsync" this should be a file system path, eg '/' or '/home'.

For $Conf{XferMethod} = "rsyncd" this should be the name of the module to backup (ie: the name from /etc/rsynd.conf).

This can also be a list of multiple file system paths or modules. For example, by adding --one-file-system to $Conf{RsyncArgs} you can backup each file system separately, which makes restoring one bad file system easier. In this case you would list all of the mount points:

    $Conf{RsyncShareName} = ['/', '/var', '/data', '/boot'];
```

中文对照：
```
$Conf{RsyncShareName} = '/';
共享名称以进行备份。对于$Conf{XferMethod} = "rsync"，这应该是文件系统路径，例如“/”或“/home”。

对于$Conf{XferMethod} = "rsyncd"，这应该是要备份的模块的名称（即：/etc/rsynd.conf 中的名称）。

这也可以是多个文件系统路径或模块的列表。例如，通过将 --one-file-system 添加到$Conf{RsyncArgs}中，您可以单独备份每个文件系统，这使得恢复一个损坏的文件系统变得更加容易。在这种情况下，您将列出所有安装点：

    $Conf{RsyncShareName} = ['/', '/var', '/data', '/boot'];
```

文新一言中关于`--one-file-system`的解释
```
Q:rsync参数--one-file-system的含义

A:rsync 是一个用于在本地和远程文件系统之间同步文件和目录的工具。--one-file-system 是 rsync 的一个参数，其意义如下：

当使用 --one-file-system 参数时，rsync 只会复制与指定源目录位于同一文件系统上的文件和目录。换句话说，它不会跨文件系统边界复制数据。

举个例子，如果你有一个挂载点（如 /mnt/data），并且该挂载点指向一个与根文件系统（/）不同的文件系统，那么当你尝试使用 rsync 复制 / 目录时，如果不使用 --one-file-system 参数，rsync 会尝试复制 /mnt/data 下的内容（如果它存在的话）。但是，如果你使用了 --one-file-system 参数，那么 /mnt/data 下的内容将不会被复制，因为 /mnt/data 是在一个与 / 不同的文件系统上。

这个参数在某些情况下可能很有用，特别是当你只想复制特定文件系统上的数据时，或者当你不想复制可能包含大量数据的挂载点时。但请注意，这可能会导致数据不完整，特别是如果某些重要的数据存储在挂载点上时。因此，在使用此参数之前，请确保你了解它的影响。
```


[1]: https://github.com/HanXHX/ansible-backuppc
[2]: https://github.com/Leif160519/docker-script/tree/master/backuppc
