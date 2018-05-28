#!/bin/bash
bond=bond0
rfc=16392
cc=$(grep -c processor /proc/cpuinfo)
rsfe=$(($cc*$rfc))

sysctl -w net.core.rps_sock_flow_entries=$rsfe
dmidecode -t system | grep -i huawei && cat /proc/net/bonding/$bond  | awk '$0~/Slave Interface:/ {print $NF}' | while read nic
do
    node=$(cat /sys/class/net/$nic/device/numa_node)
    [[ -z $node ]] && echo not found numa && exit 1
    [[ -z $nic ]] && echo not found bond && exit 1
    echo "the nic is $nic in the node-$node"
    service iptables stop
    ethtool -G $nic rx 8192 tx 1024
    ethtool -G $nic rx 8192 tx 1024
    ethtool -K $nic lro on
    ethtool -K $bond lro on
    service irqbalance stop

    if [ -n $node ];then
          echo "bind int to node $node"
          set_irq_affinity_bynode.sh $node $nic
    fi

    for fileRps in $(ls /sys/class/net/${nic}/queues/rx-*/rps_cpus)
    do
           #echo 0000,00000000,00000000,00003fff >$fileRps
           [[ $node -eq 1 ]] && echo 0000,00000000,00000000,0ff00000 >$fileRps
    done

    for fileRfc in $(ls /sys/class/net/${nic}/queues/rx-*/rps_flow_cnt)
    do
           echo $rfc >$fileRfc
    done

    for fileRps in $(ls /sys/class/net/${nic}/queues/tx-*/xps_cpus)
    do
           #echo 0000,00000000,00000000,000000ef >$fileRps
           [[ $node -eq 1 ]] && echo 0000,00000000,00000000,000fc000 >$fileRps
    done
done
