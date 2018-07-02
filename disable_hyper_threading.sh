#!/bin/bash

for CPU in $( ls /sys/devices/system/cpu/cpu[0-9]* -d | sort); do
    awk -F '-' '{if(NF > 1) {HOTPLUG="/sys/devices/system/cpu/cpu"$NF"/online"; print "0" > HOTPLUG; close(HOTPLUG)}}' \
                $CPU/topology/thread_siblings_list 2>/dev/null;
done

#    awk -F ',' '{if(NF > 1) {HOTPLUG="/sys/devices/system/cpu/cpu"$NF"/online"; print "0" > HOTPLUG; close(HOTPLUG)}}' \
#                $CPU/topology/thread_siblings_list 2>/dev/null;
