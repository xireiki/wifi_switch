SKIPUNZIP=1

TIMESTAMP=$(date "+%Y%m%d%H%M")
PACKAGELIST="/data/system/packages.list"
BOXPATH="busybox"

if [ -f "${MODPATH}/config.sh" ]; then
	ui_print "- 检测到配置文件，正在备份"
	CONFIG=`cat "${MODPATH}/config.sh"`
fi

unzip -o "${ZIPFILE}" -x 'META-INF/*' -d ${MODPATH} >&2
set_perm_recursive ${MODPATH} 0 0 0755 0755

if [ "${KSU}" ] ; then
  BOXPATH="/data/adb/ksu/bin/busybox"
  ui_print "- 刷写过程在 KernelSU 环境下运行"
elif [ "${APATCH}" ] ; then
  BOXPATH="/data/adb/ap/bin/busybox"
  ui_print "- 刷写过程在 APatch 环境下运行"
elif [ ${MAGISK_VER_CODE} ] ; then
  BOXPATH="/data/adb/magisk/busybox"
  ui_print "- 刷写过程在 Magisk 环境下运行"
else
  ui_print "*********************************************************"
  ui_print "! 不支持的安装环境，请在 Magisk/KernelSU/APatch 环境下刷写本模块"
  abort    "*********************************************************"
fi

if ! [ -d "/data/adb/modules/SingBox_For_Magisk" ]; then
	abort "- 未检测到神秘，安装失败"
fi

install_toast(){
	if [ -n "$(cat ${PACKAGELIST} | grep "ice.toast")" ] ; then
		ui_print "- 已配置 toast 环境，跳过"
		return
	fi

readkey_install_toast:

	ui_print "***************************************~******************"
	ui_print "- 未配置 toast 环境，请根据提示按下相应按键，你将有 10s 的反应时间"
	ui_print "- 音量下/音量 -：配置 toast 环境"
	ui_print "- 音量上/音量 +：跳过"
	ui_print "****************************************~*****************"

	local SIGNAL=$(${BOXPATH} timeout 10s ${MODPATH}/libs/keycheck; echo $?)

	if [ "${SIGNAL}" = "42" ] ; then
		ui_print "- 跳过"
		rm -rf ${MODPATH}/base.apk
		return 0
	elif ! [ "${SIGNAL}" = "41" ] && ! [ "${SIGNAL}" = "${DEFAULTSIGNAL}" ] ; then
		ui_print "- 错误按键，请重新按键"
		sleep 1
		goto readkey_install_toast
	fi

	ui_print "- 配置 toast"
	pm install ${MODPATH}/libs/toast.apk
	if [ -z "$(cat ${PACKAGELIST} | grep "ice.toast")" ] ; then
		ui_print "- 配置失败，如需配置请重新刷写模块"
	fi
	rm -f ${MODPATH}/libs/toast.apk
}

if [ -n "$(cat ${PACKAGELIST} | grep "ice.toast")" ] ; then
	ui_print "- 已配置 toast 环境，跳过"
else
	install_toast
fi

if [ -n "${CONFIG}" ]; then
	ui_print "- 正在恢复你的配置"
	printf "%s" "${CONFIG}" > "${MODPATH}/config.sh"
fi

ui_print "- 安装完成，正在启动"