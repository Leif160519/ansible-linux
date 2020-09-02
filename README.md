## 一、说明
本项目源自：[centos-script](https://github.com/Leif160519/centos-script) | [ubuntu-script](https://github.com/Leif160519/ubuntu-script)

针对待执行脚本的主机数量众多的情况下，建议采用ansible刷入的方式统一配置这些机器，可以大大减少人工成本与时间成本

项目目录结构
```
├── files
│   ├── docker
│   │   ├── daemon.json
│   │   └── docker-ce.repo
│   └── repository
│       ├── CentOS-Base.repo
│       └── sources.list
├── inventory
│   ├── all
│   └── dist
├── playbooks
│   ├── config.yml
│   ├── docker.yml
│   ├── files -> ../files
│   ├── gitlab.yml
│   ├── install.yml
│   ├── oh-my-fish.yml
│   ├── oh-my-zsh.yml
│   ├── rar.yml
│   ├── remove_gnome.yml
│   ├── repository.yml
│   └── universal.yml
└── README.md
```

## 二、如何使用

- 1.选择一台Linux或Mac主机安装python3并安装ansible
```
#ubuntu
apt-get install ansible

#centos
yum -y install ansible

#macos
brew install ansible #没有装brew包管理器的自行百度安装一下
```

- 2.将本机的ssh-key全部复制进所有主机中
```
ssh-copy-id -i root@<host-ip>
```

- 3.克隆本项目
```
git clone https://github.com/Leif160519/ansible-linux
```

- 4.修改inventory下的主机hostname和IP地址
```
# all
[all]
k8s-node1         ansible_host=192.168.0.8
k8s-node2         ansible_host=192.168.0.9
k8s-node3         ansible_host=192.168.0.10
ubuntu            ansible_host=192.168.0.105

#dist
[dist]
[dist:children]
dist.ubuntu
dist.centos

[dist.centos:children]
dist.centos7


[dist.ubuntu:children]
dist.ubuntu.lts

[dist.ubuntu.lts:children]
dist.u1804
dist.u2004

[dist.centos7]
k8s-node1
k8s-node2
k8s-node3


[dist.u1804]

[dist.u2004]
ubuntu
```

- 5.ansible配置文件配置忽略组语法错误
```
vi /etc/ansible/ansible.cfg

[defaults]
force_valid_group_names = ignore
···

```
- 6.开始刷入
```
ansible-playbook -u root -i inventory/ playbooks/universal.yml
```

## 三、特定情况
- 1.安装某些软件
```
ansible-playbook -u root -i inventory/ playbooks/install.yml -t [ubuntu | base] 
```

- 2.在某些机器上指定playbook
```
ansible-playbook -u root -i inventory/ playbooks/install.yml -l 'k8s-node1 k8s-node2'
```

## 四、写在最后
由于个人精力有限，项目并不会经常更新，若大家有兴趣，可以在项目中贡献自己的代码，一起将[ansible-linux](https://github.com/Leif160519/ansible-linux)发展壮大，感谢各位的理解与支持！
