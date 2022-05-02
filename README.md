官方文档 : [Ansible Documentation][1]

## 一、说明
本项目源自：[centos-script][2] | [ubuntu-script][3]

## 二、项目介绍
- 使用到的特性：lineinfile,blockinfile,template,user,roles,package,apt,yum,service,systemd,handlers,notify等
- 推荐目标主机系统版本：Ubuntu 16.04,Centos 7,Debian 9

## 三、项目目录结构
```
ansible-linux
├── ansible.cfg                         // ansible 配置文件，优先级最高，其次为/etc/ansible/ansible.cfg
├── files                               // 模板文件，非roles中的
├── group_vars                          // 全局环境变量
├── inventory                           // 机器分组列表
│   ├── all                               // 所有机器，不分组
│   ├── os                                // 按操作系统版本分类
│   └── pro                               // 按项目或集群分类
├── LICENSE                             // 开源许可证
├── playbooks                           // 各种剧本
│   ├── backuppc.yml                      // backuppc配置剧本
│   ├── config.yml                        // 系统配置剧本
│   ├── files -> ../files
│   ├── group_vars -> ../group_vars
│   ├── install.yml                       // 软件安装剧本
│   ├── prometheus.yml                    // p8s配置剧本
│   ├── repository.yml                    // 仓库源配置剧本
│   ├── uninstall.yml                     // 软件卸载剧本
│   └── universal.yml                     // 集合，通用剧本
├── README.md                           // 自述文件
└── roles                               // 角色
    ├── ahuffman.resolv                   // 配置/etc/resolved.conf
    ├── cloudalchemy.prometheus           // 安装和配置prometheus服务器
    ├── geerlingguy.ntp                   // 安装和配置ntp时间同步
    ├── leif160519.backuppc               // 配置backuppc服务器(不包含安装)
    ├── leif160519.clickhouse-cluster     // 安装配置clickhouse集群
    ├── leif160519.docker                 // 安装和配置docker
    ├── leif160519.kafka-cluster          // 安装kafka集群2.x
    ├── leif160519.minio-cluster          // 安装minio集群
    ├── leif160519.moosefs                // 安装moosefs分布式存储集群
    ├── leif160519.mysql                  // 安装和配置mysql5.7.28
    ├── leif160519.nacos-cluster          // 安装nacos集群2.0
    ├── leif160519.network                // 配置静态ip地址
    ├── leif160519.oh-my-zsh              // 安装和配置oh-my-zsh
    ├── leif160519.redis-cluster          // 编译安装和配置redis集群6.x
    ├── leif160519.vim-complex            // 配置vim-简单版
    ├── leif160519.vim-simple             // 配置vim-复杂版，带智能语法提示
    └── leif160519.zookeeper-cluster      // 安装zookeeper集群3.5.9
```

## 四、如何使用

- 1.选择一台Linux或Mac主机安装python3并安装ansible
```
#ubuntu
apt-get install ansible

#centos
yum -y install ansible

#macos
brew install ansible

# python
pip3 install ansible
```

- 2.将本机的ssh-key全部复制进所有目标主机中
```
ssh-copy-id -i root@<host-ip>
```

- 3.克隆本项目
```
git clone https://github.com/Leif160519/ansible-linux
```

- 4.根据实际情况修改inventory下的主机hostname和IP地址
> all: 所有机器,若目标主机ssh端口不为22,请在`ansible_host`后新增一列`ansible_port=<ssh_port>`

> os：根据系统版本进行分类

> pro: 根据集群或者项目进行分类


- 5.ansible配置文件-`ansible.cfg`(使用pip3安装的ansible不会生成配置文件，可手动创建并配置，或者直接引用项目目录下的ansible.cfg(执行时会优先生效))
使用代理进行ssh远程主机:
```
vim ansible.cfg(/etc/ansible/ansible.cfg)

[ssh_connection]
ssh_args = -o ProxyCommand="nc -X connect -x 127.0.0.1:3128 %h %p"

```
请将`127.0.0.1:3128`改为真实有效的代理地址

- 6.开始刷入(若使用代理上网，请添加参数`-e proxy_url="http://example.com:3128"`,支持http和socks5)
```
# all machine(prometheus.yml auto install node_exporter)
ansible-playbook -u root -i inventory/ playbooks/universal.yml

# prometheus-server(以下顺序不能颠倒)
# 1.pull submodle
git submodule update --init --recursive
# 2.install prometheus
ansible-playbool -u root -i inventory/ playbooks/prometheus.yml -t prometheus
# 3.install alertmanager
ansible-playbook -u root -i inventory/ playbooks/prometheus.yml -t alertmanager
# 4.install blackbox_exporter
ansible-playbook -u root -i inventory/ playbooks/prometheus.yml -t blackbox
# 5.config prometheus and start prometheus service
ansible-playbook -u root -i inventory/ playbooks/prometheus.yml -t admin
```

## 五、特定情况
- 1.安装某些软件
```
ansible-playbook -u root -i inventory/ playbooks/install.yml -t general
```

- 2.在某些机器上指定playbook
```
ansible-playbook -u root -i inventory/ playbooks/install.yml -l 'jenkins-server nexus-server'
```

- 3.监控主机安装prometheus
执行`prometheus.yml`之后别忘了执行一下`node_exporter.yml`，否则`9090`不能显示监控数据

- 4.被监控主机安装node_exporter
需在`node_export.yml`文件中将`delegate_to`后面的`prometheus`主机名按照实际情况修改之后再执行

- 5.安装node_exporter时报错解决办法
在某些情况下，执行带有`delegate_to`（任务委派）的playbook时候，会报错：
```
failed: [centos-7 -> 192.168.0.108] (item=  - job_name: 'node') => {"ansible_loop_var": "item", "changed": false, "item": "  - job_name: 'node'", "module_stderr": "Shared connection to 192.168.0.108 closed.\r\n", "module_stdout": "/bin/sh: 1: /usr/bin/python: not found\r\n", "msg": "The module failed to execute correctly, you probably need to set the interpreter.\nSee stdout/stderr for the exact error", "rc": 127}

failed: [debian-10 -> 192.168.0.108] (item=  - job_name: 'node') => {"ansible_loop_var": "item", "changed": false, "item": "  - job_name: 'node'", "module_stderr": "Shared connection to 192.168.0.108 closed.\r\n", "module_stdout": "/bin/sh: 1: /usr/bin/python3.7: not found\r\n", "msg": "The module failed to execute correctly, you probably need to set the interpreter.\nSee stdout/stderr for the exact error", "rc": 127}
```

原因是ansible未检测到python环境，也就是说你在Linux终端打`python`是提示无此命令的，所以解决办法是，强制ansible使用python3环境，在执行命令后面添加`-e ansible_python_interpreter=/usr/bin/python3`参数即可：
```
ansible-playbook -u root -i inventory playbooks/node_exporter.yml  -l 'jenkins-server' -e ansible_python_interpreter=/usr/bin/python3
```

## 六、说明
- 1.prometheus自带三条规则，分别为"分区剩余空间不足2%","分区剩余空间使用预计不足4h"和"ping有丢包"
- 2.项目中的部分文件已经配置了在vim下的自动折叠功能(依据标志),其他折叠方式如下：

```
1. manual //手工定义折叠
2. indent //用缩进表示折叠
3. expr　 //用表达式来定义折叠
4. syntax //用语法高亮来定义折叠
5. diff   //对没有更改的文本进行折叠
6. marker //用标志折叠
```

在vim的配置文件中设置`set foldmethod=marker`或者通过ansible刷入即可：
```
ansible-playbook -u root -i inventory playbooks/vim-simple -e username=<username>
```

## 七、补充内容

### 7.1 git代码统计工具
#### 1) svn转化为git:git-svn
- 安装：`apt-get install git-svn`
- 下载svn库：`git-svn clone <svn_uri>`
- 更新svn库：`git-svn rebase`

#### 2) git代码图形化报表：[gitstats][7];[gitinspector][8];git-bars
- 安装：
```
apt-get install gitstats(ubuntu 20.04请先安装gnuplot-nox，之后可以去下载gitstats_2015.10.03-1_all.deb之后再安装)
apt-get install gitinspector
pip3 install git-bars
```
- 生成报表：
```
gitstats <git_dir> <report_dir>
gitinspector <git_dir> -HTLlrw --since="2021-01-01" -F html > index.html
git-bars
 ```

### 八、已知的问题(截止2021-02-01)
- ansible中的service模块(systemd版本:245.4)与内核版本为5.8的linux不兼容，会报`FAILED! => {"changed": false, "msg": "Service is in unknown state", "status": {}}`，建议内核版本5.8基础上升级systemd版本至245.7及以上或降级Linux内核版本,详情参看:[Service is in unknown state #71528][4] | [ansible fails with systemd 245.4][5]
- 当执行ntp.yml时，若远程机器是ubuntu20.04的系统请将ansible版本升级至2.9.8以上或使用2.10(使用pip3而不是apt安装)，详情参看:[Problems on Ubuntu 20.04 #86][6]

### 九、监控nginx
执行nginx_exporter之前，需提前配置好nginx中的/stub_status,剧本中使用的是8080端口，也可以更换成其他端口，另外，监控信息最好只对p8s服务器开放访问，其他ip可以禁止，配置示例如下：
```
server {
    listen 8080;
    location /stub_status {
        stub_status on;
        allow 10.1.1.24;
        deny all;
    }
}
```

[1]:  https://docs.ansible.com/
[2]:  https://github.com/Leif160519/centos-script
[3]:  https://github.com/Leif160519/ubuntu-script
[4]:  https://github.com/ansible/ansible/issues/71528
[5]:  https://bugs.launchpad.net/ubuntu/+source/systemd/+bug/1899232
[6]:  https://github.com/geerlingguy/ansible-role-ntp/issues/86
[7]: http://gitstats.sourceforge.net/
[8]: https://github.com/ejwa/gitinspector
