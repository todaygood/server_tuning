#!/bin/bash

grep -H . /sys/devices/system/cpu/cpu*/topology/thread_siblings_list | sort -n -t ':' -k 2 -u
#grep -H . /sys/devices/system/cpu/cpu*/topology/thread_siblings_list | sort -n -t ',' -k 2 -u


# https://access.redhat.com/solutions/352663
