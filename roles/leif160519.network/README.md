## Ansible Role: Network
设置静态IP

## 系统要求
- Debian
- Ubuntu
- RedHat(Centos,Fedora)

## 用法
```
vars:
  dns1: 180.76.76.76
  dns2: 114.114.114.114
  search: localdomain
roles:
  - role: roles/leif160519.network
```
> 参数解释
> - `dns1/dns2`: dns解析地址，必须写
> - `search`: 搜索域，如果没有就写`localdomain`
