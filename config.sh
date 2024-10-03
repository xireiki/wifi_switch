# 重要: 有空格等特殊字符的行，一定要加上引号！
# 重要: 有空格等特殊字符的行，一定要加上引号！
# 重要: 有空格等特殊字符的行，一定要加上引号！

force_need_ssid=true
## 有两个值: true 和 false
### true: 在 WiFi 开启时，要求连上 WiFi 才算开启
### false: 只要 WiFi 开启就算开启

use_custom_direct=false
## 有两个值: true 和 false
### true: 直连时使用 <direct_outbound_list> 或 <direct_mode_list> 而不是 <direct_outbound> 或 <direct_mode>
### false: 使用 <direct_outbound>

mode=switch
## 有 3 种模式
### switch: WiFi 下关闭神秘, 移动数据下打开
### selector: WiFi 下选择 <direct_outbound>, 移动数据下如果 <proxy_outbound> 为空则恢复原选择
### mode: WiFi 下选择 <direct_mode>, 移动数据下如果 <proxy_mode> 为空则恢复原选择

select_outbound=国内出口
## selector 模式下切换的出站

default_outbound=本机直连
## selector 模式下没有历史记录时断开 WiFi 的默认选择

direct_outbound=本机直连
## WiFi 下切换的出站，需要填写的出站存在于 <select_outbound> 设置的出站内

proxy_outbound=
## 数据下切换的出站，为空默认为原出站，建议填写

direct_outbound_list=""
## 自定义不同 WiFi 下选择的出站
### 格式1: SSID:出站
### 格式2: SSID,出站;SSID1,出站1
### 例如有一个 WiFi 名为 Ciallo，需要连上时走 柚子直连
###  另有一个 WiFi 名为 爱莉希雅世界第一，需要连上时走 十三英桀
###  是这样写
###  Ciallo,柚子直连;爱莉希雅世界第一,十三英桀
###  记得包含在引号内，也就是这样
###  direct_outbound_list="Ciallo,柚子直连;爱莉希雅世界第一,十三英桀"
###  切记使用英文逗号( , )和英文分号( ; )

direct_mode=规则模式-我不免流-FakeIP
## mode 模式下，在 WiFi 开启时自动选择的 clash mode

proxy_mode=规则模式-我要免流-FakeIP
## mode 模式下，在 WiFi 关闭时自动选择的 clash mode

direct_mode_list=""
## 自定义不同 WiFi 下选择的 clash_mode
### 格式1: SSID,模式
### 格式2: SSID,模式;SSID1,模式1
### 例如有一个 WiFi 名为 Ciallo，需要连上时走 规则模式-我不免流-FakeIP
###  另有一个 WiFi 名为 爱莉希雅世界第一，需要连上时走 规则模式-我不免流-RedirHost
###  是这样写
###  Ciallo,规则模式-我不免流-FakeIP;爱莉希雅世界第一,规则模式-我不免流-RedirHost
###  记得包含在引号内，也就是这样
###  direct_mode_list="Ciallo,规则模式-我不免流-FakeIP;爱莉希雅世界第一,规则模式-我不免流-RedirHost"
###  切记使用英文逗号( , )和英文分号( ; )
###  多个选项之间使用英文分号(;)分割

sleep_time=5
## 两次检查 WiFi 状态之间的间隔，单位: s
