=== action_plugins/merge_vars.py
https://github.com/leapfrogonline/ansible-merge-vars

monit 的 services，散布在不同的 group_vars 和 host_vars。
某些资产，属于多个 group，本应该从各个 group 继承对应的 services，
但是由于 ansible 默认的覆盖(override)行为，导致变量无法自动合并。

依赖 `pip3 install ansible-merge-vars`

=== mount_leif160519.py
原生的 mount 模块的 absent 动作，不仅从 fstab 移除挂载点，
而且还会执行 umount、以及更过分的 rm 删除挂载点目录的动作。

因为不希望对系统执行 umount 和 rm 这样的危险动作，
所以从原生模块继承并修改得到了自定义的 mount_leif160519 模块。
