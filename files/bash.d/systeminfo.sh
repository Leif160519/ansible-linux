#!/bin/bash
# by 运维朱工
# site：bash.lutixia.cn
####################################



# 获取IP地址和主机名
IP_ADDR=$(hostname -I | cut -d' ' -f1)
HOSTNAME=$(hostname)

# CPU负载信息：
cpu_load() {
    echo -e "\t\t\tcpu的负载情况"
    echo -e "\t------------------------------------------------"
    echo -e "\tCPU load in 1  min is: `awk  '{printf "%15s",$1}' /proc/loadavg`"
    echo -e "\tCPU load in 5  min is: `awk  '{printf "%15s",$2}' /proc/loadavg`"
    echo -e "\tCPU load in 10 min is: `awk  '{printf "%15s",$3}' /proc/loadavg`"
    echo
}

# mem基本信息：
memory_info() {
    echo -e "\t\t\t内存的使用情况"
    echo -e "\t------------------------------------------------"
    echo -e "\t`free -h | awk '/Mem/{printf "%-10s %s","内存总容量:",$2}'`"
    echo -e "\t`free -h | awk '/Mem/{printf "%-10s %s","内存空闲容量:",$4}'`"
    echo -e "\t`free -h | awk '/Mem/{printf "%-10s %s","内存缓存:",$6}'`"
    echo
}

# 磁盘使用量排序：
disk_rank() {
    echo -e "\t\t\t各分区使用率"
    echo -e "\t------------------------------------------------"
    df -h  -x tmpfs -x devtmpfs | sort -nr -k 5 | awk '/dev/{printf "\t%-20s %10s\n", $1, $5}'
    echo
}

# 显示系统信息
echo
echo -e "\t\t\t系统基本信息："
echo -e "\t------------------------------------------------"
echo -e "\tCurrent Time : $(date)"
echo -e "\tVersion      : $(cat /etc/os-release | grep -w "PRETTY_NAME" | cut -d= -f2 | tr -d '"')"
echo -e "\tKernel       : $(uname -r)"
echo -e "\tUptime       : $(uptime -p)"
echo -e "\tIP addr      : $IP_ADDR"
echo -e "\tHostname     : $HOSTNAME"
echo -e "\tCpu          : $(lscpu | grep "Model name:" | sed 's/Model name:\s*//')"
echo -e "\tMemory       : $(free -h | awk '/^Mem:/ { print $3 "/" $2 }')"
echo -e "\tSWAP         : $(free -h | awk '/^Swap:/ { print $3 "/" $2 }')"
echo -e "\tUsers Logged : $(who | wc -l) users"
echo

cpu_load
memory_info
disk_rank
