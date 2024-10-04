#!/system/bin/sh

wifi(){
	return $(expr 1 - `settings get global wifi_on`)
}

wifi1(){
	local sta
	sta=$(dumpsys wifi | grep "Wi-Fi is ")
	if [ -n "`echo ${sta} | grep enabled`" ]; then
		return 0
	elif [ -n "`echo ${sta} | grep disabled`" ]; then
		return 1
	else
		return 2
	fi
}

ssid(){
	if wifi; then
		local SSID
		SSID=$(dumpsys wifi | grep mWifiInfo | head -n 1 | cut -d "\"" -f 2)
		if [ -n "$(printf "%s" "${SSID}" | grep "<unknown ssid>")" ]; then
			printf "<unknown ssid>"
			return
		fi
		printf "%s" "${SSID}"
	else
		printf "%s" "<unknown ssid>"
		return 1
	fi
}

connected(){
	if [ -z "$(cat /data/misc/net/rt_tables | grep wlan)" ]; then
		return 1
	fi
}

load(){
	if [ -n "$1" ]; then
		. $1
	else
		. ${MODDIR}/config.sh
	fi
}

prop_md5(){
	md5sum ${MODDIR}/config.sh | cut -d " " -f 1
	return $?
}

getKey(){
	awk '/authorizationKey/{print $2}' /data/adb/sfm/src/config.yaml
	return $?
}

getSecret(){
	if [ "${UseCompatibleMode}" = "true" ]; then
		printf "%s" "${clash_api_secret}"
		return
	fi
	if ! status; then
		return 1
	fi
	curl "127.0.0.1:23333/api/kernel" -H "authorization: $(getKey)" -H "Content-Type: application/json" 2>/dev/null | tr ',' "\n" | awk -F '[:,]' '/"secret"/{gsub(/.*"secret":"|"/, "", $2); print $2}'
	return $?
}

getPort(){
	if [ "${UseCompatibleMode}" = "true" ]; then
		printf "%s" "${clash_api_port}"
		return
	fi
	if ! status; then
		return 1
	fi
	curl "127.0.0.1:23333/api/kernel" -H "authorization: $(getKey)" -H "Content-Type: application/json" 2>/dev/null | tr ',' "\n" | awk -F '[:,]' '/"port"/{gsub(/.*"port":"|"/, "", $2); print $2}'
	return $?
}

status(){
	if [ "${UseCompatibleMode}" = "true" ]; then
		curl "127.0.0.1:9999/configs" &>/dev/null
		if ! [ $? = 0 ]; then
			return 1
		fi
		return
	fi
	local sta
	sta=$(curl "127.0.0.1:23333/api/kernel" -H "authorization: $(getKey)" -H "Content-Type: application/json" 2>/dev/null | tr ',' "\n" | awk -F '[:,]' '/"status"/{gsub(/.*"status":"|"\}|"/, "", $2); print $2}')
	if [ "${sta}" = "working" ]; then
		return 0
	elif [ "${sta}" = "stopped" ]; then
		return 1
	elif [ "${sta}" = "stopping" ]; then
		return 2
	elif [ "${sta}" = "starting" ]; then
		return 3
	else
		return 4
	fi
}

stop_core(){
	if [ "${UseCompatibleMode}" = "true" ]; then
		toast "short" "兼容模式不支持 switch 模式"
		return 1
	fi
	curl "127.0.0.1:23333/api/kernel" -H "authorization: $(getKey)" -H "Content-Type: application/json" -d '{"method":"stop"}' &>/dev/null
	if ! [ $? = 0 ]; then
		return 1
	fi
}

start_core(){
	if [ "${UseCompatibleMode}" = "true" ]; then
		toast "short" "兼容模式不支持 switch 模式"
		return 1
	fi
	curl "127.0.0.1:23333/api/kernel" -H "authorization: $(getKey)" -H "Content-Type: application/json" -d '{"method":"start"}' &>/dev/null
	if ! [ $? = 0 ]; then
		return 1
	fi
}

setOutbound(){
	if [ -z "$1" ]; then
		return 1
	fi
	if [ -z "$2" ]; then
		return 1
	fi
	local secret
	secret=$(getSecret)
	if [ -n "${secret}" ]; then
		curl -X PUT "127.0.0.1:$(getPort)/proxies/$1" -H "authorization: Bearer ${secret}" -H "Content-Type: application/json" -d '{"name": "'$2'"}'
		return
	fi
	curl -X PUT "127.0.0.1:$(getPort)/proxies/$1" -H "Content-Type: application/json" -d '{"name": "'$2'"}'
}

setMode(){
	if [ -z "$1" ]; then
		return 1
	fi
	local secret
	secret=$(getSecret)
	if [ -n "${secret}" ]; then
		curl -X PATCH "127.0.0.1:$(getPort)/configs" -H "authorization: Bearer $(getSecret)" -H "Content-Type: application/json" -d '{"mode": "'$1'"}'
		return
	fi
	curl -X PATCH "127.0.0.1:$(getPort)/configs" -H "Content-Type: application/json" -d '{"mode": "'$1'"}'
}

toast(){
	local ID=`id -u`
	if ! [ ${ID} = 1000 ] && ! [ ${ID} = 2000 ] && ! [ ${ID} = 0 ]; then
		return 1
	fi
	if [ -z "$(command -v content)" ]; then
		return 2
	fi
	if [ -z "$(cat /data/system/packages.list | grep ice.toast)" ]; then
		return 3
	fi

	local showMode="short"
	local showContent

	if [ -z "$1" ]; then
		return 4
	fi
	if [ -z "$2" ]; then
		showContent="$1"
	else
		if [ $1 = "short" ] || [ $1 = "long" ]; then
			showMode="$1"
			shift
			showContent="$*"
		else
			showContent="$*"
		fi
	fi
	content query --uri "content://ice.toast/${showMode}/${showContent}" &>/dev/null
	return $?
}

notify(){
	if [ -z "$*" ]; then
		return 1
	fi
	
	ARGS="${@}"
	VERBOSE=false
	TITLETEXT="Notification"
	ICON=""
	LARGEICON=""
	STYLE=""
	CONTENTINTENT=""
	TAG="TAG"
	
	for arg in "${@}"; do
		case "${arg}" in
		-h | --help)
			helpText && exit 0;;
		-v | --verbose)
			VERBOSE=true
			shift 1
			;;
		-t | --title)
			TITLETEXT="${2}"
			shift 2
			;;
		-I | --icon)
			ICON="${2}"
			shift 2
			;;
		-l | --large-icon)
			LARGEICON="${2}"
			shift 2
			;;
		-s | --style)
			STYLE="${2}"
			shift 2
			;;
		-c | --content-intent)
			CONTENTINTENT="${2}"
			shift 2;;
		-i | --id)
			TAG="${2}"
			shift 2;;
		esac
	done
	
	ARGV="cmd notification post"
	if [ "${VERBOSE}" = true ]; then
		ARGV="${ARGV} -v"
	fi
	ARGV="${ARGV} -t ${TITLETEXT}"
	if [ -n "${ICON}" ]; then
		ARGV="${ARGV} -i ${ICON}"
	fi
	if [ -n "${LARGEICON}" ]; then
		ARGV="${ARGV} -i ${LARGEICON}"
	fi
	if [ -n "${STYLE}" ]; then
		ARGV="${ARGV}${STYLE}"
	fi
	if [ -n "${CONTENTINTENT}" ]; then
		ARGV="${ARGV} -c ${CONTENTINTENT}"
	fi
	
	if [ "$(id -u)" != "2000" ]; then
		su shell -c "${ARGV} ${TAG} ${*}"
		if [ "$?" != "0" ]; then
			return 2
		fi
	fi
}

getTarget(){
	printf "%s" "$1" | tr ';' "\n" | awk -F ',' '/'"$2"'/{gsub(/.*'"$2"',/, "", $2); print $2}'
}

getNowOutbound(){
	secret=$(getSecret)
	if [ -n "${secret}" ]; then
		curl "127.0.0.1:$(getPort)/proxies/${select_outbound}" -H "authorization: Bearer ${secret}" -H "Content-Type: application/json" 2>/dev/null | tr ',' "\n" | awk -F '[:,]' '/"now"/{gsub(/.*"now":"|"/, "", $2); print $2}'
	fi
	curl "127.0.0.1:$(getPort)/proxies/${select_outbound}" -H "Content-Type: application/json" 2>/dev/null | tr ',' "\n" | awk -F '[:,]' '/"now"/{gsub(/.*"now":"|"/, "", $2); print $2}'
}

getNowMode(){
	secret=$(getSecret)
	if [ -n "${secret}" ]; then
		curl "127.0.0.1:$(getPort)/configs" -H "authorization: Bearer ${secret}" -H "Content-Type: application/json" 2>/dev/null | tr ',' "\n" | awk -F '[:,]' '/"mode"/{gsub(/.*"mode":"|"/, "", $2); print $2}'
		return
	fi
	curl "127.0.0.1:$(getPort)/configs" -H "Content-Type: application/json" 2>/dev/null | tr ',' "\n" | awk -F '[:,]' '/"mode"/{gsub(/.*"mode":"|"/, "", $2); print $2}'
}
