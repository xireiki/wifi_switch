#!/system/bin/sh

MODDIR=${0%/*}

until [ $(getprop sys.boot_completed) -eq 1 ] ; do
  sleep 3
done

. ${MODDIR}/config.sh

if ! [ "${UseCompatibleMode}" = "true" ] && [ ! -d "/data/adb/modules/SingBox_For_Magisk" ]; then
	. ${MODDIR}/libs/utils.sh
	notify -t "WLAN Switching" "未安装神秘模块并且未开启兼容模式，将在下次开机卸载本模块。模块已停止运行"
	touch ${MODDIR}/disable
	touch ${MODDIR}/remove
	exit
fi

inotifyd ${MODDIR}/libs/inotify.sh /data/misc/net/rt_tables
