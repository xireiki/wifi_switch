#!/system/bin/sh

MODDIR=${0%/*}
DataPath="/data/adb/sfm"
. ${MODDIR}/libs/utils.sh

load
configHash=`prop_md5`

Outbound=
ClashMode=

switchMode(){
	if [ "${UseCompatibleMode}" = "true" ]; then
		toast "short" "兼容模式不支持 switch 模式"
		return
	fi
	local sta="$(status; echo $?)"
	if $1; then # disconnect, on CellularNetwork
		if [ "${sta}" = 1 ]; then
			start
		elif [ "${sta}" = 2 ] || [ "${sta}" = 3 ]; then
			sleep 1
			switchMode $@
		fi
	else # connect, on WiFi
		if [ "${sta}" = 0 ]; then
			stop
		elif [ "${sta}" = 2 ] || [ "${sta}" = 3 ]; then
			sleep 1
			switchMode $@
		fi
	fi
}

selectMode(){
	local sta="$(status; echo $?)"
	if $1; then # disconnect, on CellularNetwork
		if [ "${sta}" = 1 ]; then
			local target
			target="${default_outbound}"
			if [ -n "${Outbound}" ]; then
				target="${Outbound}"
			fi
			if [ -n "${proxy_outbound}" ]; then
				target="${proxy_outbound}"
			fi
			setOutbound "${select_outbound}" "${target}"
		elif [ "${sta}" = 2 ] || [ "${sta}" = 3 ]; then
			sleep 1
			selectMode $@
		fi
	else # connect, on WiFi
		if [ "${sta}" = 0 ]; then
			local target
			if [ "${use_custom_direct}" = "true" ]; then
				local ssid=`ssid`
				target=`getTarget "${direct_outbound_list}" "${ssid}"`
			else
				target="${direct_outbound}"
			fi
			Outbound=`getNowOutbound`
			setOutbound "${select_outbound}" "${direct_outbound}"
		elif [ "${sta}" = 2 ] || [ "${sta}" = 3 ]; then
			sleep 1
			selectMode $@
		fi
	fi
}

clashMode(){
	local sta="$(status; echo $?)"
	if $1; then # disconnect, on CellularNetwork
		if [ "${sta}" = 0 ]; then
			local target
			target="${default_mode}"
			if [ -n "${ClashMode}" ]; then
				target="${ClashMode}"
			fi
			if [ -n "${proxy_mode}" ]; then
				target="${proxy_mode}"
			fi
			setMode "${target}"
		elif [ "${sta}" = 2 ] || [ "${sta}" = 3 ]; then
			sleep 1
			clashMode $@
		fi
	else # connect, on WiFi
		if [ "${sta}" = 0 ]; then
			local target
			if [ "${use_custom_direct}" = "true" ]; then
				local ssid=`ssid`
				target=`getTarget "${direct_mode_list}" "${ssid}"`
			else
				target="${direct_mode}"
			fi
			ClashMode=`getNowMode`
			setMode "${target}"
		elif [ "${sta}" = 2 ] || [ "${sta}" = 3 ]; then
			sleep 1
			clashMode $@
		fi
	fi
}

if ! [ -d "/data/adb/modules/SingBox_For_Magisk" ] && ! [[ "${UseCompatibleMode}" = "true" ]]; then
	touch ${MODDIR}/disable
	touch ${MODDIR}/remove
	exit
fi

while true; do
	nowConfigHash=`prop_md5`
	if ! [ "${nowConfigHash}" = "${configHash}" ]; then
		load
	fi
	if wifi || wifi1; then
		local sta=0
		if [ "${force_need_ssid}" = "true" ]; then
			sta=1
		fi
		case ${mode} in
			switch)
				switchMode ${sta};;
			selector)
				selectMode ${sta};;
			mode)
				clashMode ${sta};;
			*)
				toast "short" "未知的模式: ${mode}";;
		esac
	else
		case ${mode} in
			switch)
				switchMode 1;;
			selector)
				selectMode 1;;
			mode)
				clashMode 1;;
			*)
				toast "short" "未知的模式: ${mode}";;
		esac
	fi
	sleep ${sleep_time}
done
