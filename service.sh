#!/system/bin/sh

MODDIR=${0%/*}

inotifyd ${MODDIR}/inotify.sh /data/misc/net/rt_tables
