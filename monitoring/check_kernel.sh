#!/bin/bash
###################################
#
#     Check if the system is running the latest kernel
#     or if a reboot is necessary
#
#     by Martin Scharm <https://binfalse.de/contact>
#
#
###################################

source /usr/lib/nagios/plugins/utils.sh



current_kernel=$(uname -r)

latest_kernel=$(find /boot/vmlinuz-* | sort -V | tail -1 | sed 's/.*vmlinuz-//')

if [ "$current_kernel" = "$latest_kernel" ]
then
    echo "running kernel is $current_kernel"
    exit ${STATE_OK}
else
    echo "your kernel $current_kernel is outdated, please boot into $latest_kernel"
    exit ${STATE_WARNING}
fi

