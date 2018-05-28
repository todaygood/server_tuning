#!/bin/bash

bond_list="bond0 bond1"
rfc=16392

#param1: nic 
set_xps_for_nic()
{
	for fileRps in $(ls /sys/class/net/$1/queues/tx-*/xps_cpus)
	do
		echo 0003ff,f0003fff > $file
	done
}


set_rps_for_sys()
{
	cc=$(grep -c processor /proc/cpuinfo)
	rsfe=$(($cc*$rfc))
	sysctl -w net.core.rps_sock_flow_entries=$rsfe
}

#param1: nic 
set_rps_for_nic()
{
	for file in $(ls /sys/class/net/$1/queues/rx-*/rps_flow_cnt)
	do
	        echo $rfc> $file
	done

	for file in $(ls /sys/class/net/$1/queues/rx-*/rps_cpus)
	do
		echo 0003ff,f0003fff > $file
	done
}

#param1: nic 
set_nic_bind_numa_node()
{
	node=$(cat /sys/class/net/$1/device/numa_node)
	if [ -n $node ];then
	  echo "bind $1 to node $node"
	  set_irq_affinity_bynode.sh $node $nic
	fi
}

#param1: nic 
set_nic_parameter()
{
    ethtool -G $1 rx 8192 tx 1024
    ethtool -G $1 rx 8192 tx 1024
    ethtool -K $1 lro on
}

#param1: nic 
set_nic_irq_to_cpu()
{
	set_irq_affinity_cpulist.sh 0-13,28-41 $1
}

service iptables stop
service irqbalance stop

set_rps_for_sys

for bond in $bond_list
do

	dmidecode -t system | grep -i huawei && cat /proc/net/bonding/$bond  | awk '$0~/Slave Interface:/ {print $NF}' | while read nic
	do
	    [[ -z $nic ]] && echo not found bond && exit 1
	    echo "the nic is $nic in the node-$node"
	    set_nic_bind_numa_node $nic
            
            echo "nic parameter"
	    ethtool -K $bond lro on
	    set_nic_parameter $nic
	
            echo "set rps..."	
            set_rps_for_nic $nic
	
            echo "set xps..."           
	    set_xps_for_nic $nic 

	done
done




