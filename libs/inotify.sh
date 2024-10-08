#!/system/bin/sh

events=$1

if ! [ "${events}" = w ]; then
	return
fi

MODDIR=${0%/*}
DataPath="/data/adb/sfm"
. ${MODDIR}/utils.sh
load ${MODDIR}/../config.sh

if [ -f "${MODDIR}/../run/.lastOutbound" ]; then
	Outbound="$(cat "${MODDIR}/../run/.lastOutbound")"
fi
if [ -f "${MODDIR}/../run/.lastClashMode" ]; then
	ClashMode="$(cat "${MODDIR}/../run/.lastClashMode")"
fi

switchMode(){
	if [ "${UseCompatibleMode}" = "true" ]; then
		toast "short" "兼容模式不支持 switch 模式"
		return
	fi
	local sta="$(status; echo $?)"
	if [ $1 = 0 ]; then # disconnect, on CellularNetwork
		if [ "${sta}" = "1" ]; then
			start_core
			sleep 3
		elif [ "${sta}" = 2 ] || [ "${sta}" = 3 ]; then
			sleep 1
			switchMode $@
		fi
	else # connect, on WiFi
		if [ "${sta}" = "0" ]; then
			stop_core
			sleep 3
		elif [ "${sta}" = 2 ] || [ "${sta}" = 3 ]; then
			sleep 1
			switchMode $@
		fi
	fi
}

selectMode(){
	local sta="$(status; echo $?)"
	if [ $1 = 0 ]; then # disconnect, on CellularNetwork
		if [ "${sta}" = 0 ]; then
			local target="${default_outbound}"
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
			getNowOutbound > "${MODDIR}/../run/.lastOutbound"
			setOutbound "${select_outbound}" "${direct_outbound}"
		elif [ "${sta}" = 2 ] || [ "${sta}" = 3 ]; then
			sleep 1
			selectMode $@
		fi
	fi
}

clashMode(){
	local sta="$(status; echo $?)"
	if [ $1 = 0 ]; then # disconnect, on CellularNetwork
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
			getNowMode > "${MODDIR}/../run/.lastClashMode"
			setMode "${target}"
		elif [ "${sta}" = 2 ] || [ "${sta}" = 3 ]; then
			sleep 1
			clashMode $@
		fi
	fi
}

if [ -f "${MODDIR}/../disable" ]; then
	exit
fi

if wifi || wifi1; then
	sta1=0
	if [ "${force_need_ssid}" = "true" ]; then
		if connected; then
			sta1=1
		fi
	fi
	if [ "${sta1}" = 0 ]; then
		exit
	fi
	case ${mode} in
		switch)
			switchMode ${sta1};;
		selector)
			selectMode ${sta1};;
		mode)
			clashMode ${sta1};;
		*)
			toast "short" "未知的模式: ${mode}";;
	esac
else
	case ${mode} in
		switch)
			switchMode 0;;
		selector)
			selectMode 0;;
		mode)
			clashMode 0;;
		*)
			toast "short" "未知的模式: ${mode}";;
	esac
fi
