#!/bin/bash
#set -x

# trap
trap 'echo -e "\nabort: signal trapped\n"; exit 1' 1 2 3 15

echo
echo "Starting..."
echo

# config {{{

cwd=$(pwd)
swd=`(cd \`dirname $0\` && pwd)`

iptables="$(which iptables) -v "
loglevel="--log-level debug"

localnet=`cat <<"_EOT_"
#sample
192.168.1.1/24
_EOT_`

localnet=$(echo -e "$localnet" | grep -v ^# | grep -v ^$)

# }}}
# stop iptables {{{

# iptablesを停止
/etc/rc.d/init.d/iptables stop

# 既存のルールをすべて破棄
$iptables -F
$iptables -Z
$iptables -X

# }}}
# default rules {{{

# 受信は破棄、送信は許可、通過は破棄
$iptables -P INPUT   DROP
$iptables -P OUTPUT  ACCEPT
$iptables -P FORWARD DROP

# 接続済みのTCPパケットは許可
$iptables -A INPUT -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT

# loインターフェースの通信は許可
$iptables -A INPUT -p all -i lo -j ACCEPT

# 信頼できるlocalnetからの通信は許可
#$iptables -A INPUT -p all -i eth1 -j ACCEPT
for i in $localnet
do
  $iptables -A INPUT -p all -i eth1 -s $i -j ACCEPT
done

# 全ホスト(ブロードキャストアドレス、マルチキャストアドレス)宛パケットはログを記録せずに破棄
$iptables -A INPUT -d 255.255.255.255 -j DROP
$iptables -A INPUT -d 224.0.0.1       -j DROP
$iptables -A INPUT -d 0.0.0.255       -j DROP

# 外部とのNetBIOSのアクセスはログを記録せずに破棄
for i in 135 137 138 139 445
do
  $iptables -A INPUT  -p tcp --dport $i -j DROP
  $iptables -A INPUT  -p udp --dport $i -j DROP
  $iptables -A OUTPUT -p tcp --sport $i -j DROP
  $iptables -A OUTPUT -p udp --sport $i -j DROP
done

# フラグメント化されたパケットはログを記録して破棄
$iptables -A INPUT -f -j LOG $loglevel --log-prefix 'FRAGMENT DROP: '
$iptables -A INPUT -f -j DROP

# 1秒間に4回を超えるpingはログを記録して破棄
# Ping of Death 攻撃対策
$iptables -N PINGOFDEATH
$iptables -A PINGOFDEATH -m limit --limit 1/s --limit-burst 4 -j ACCEPT
$iptables -A PINGOFDEATH -j LOG $loglevel --log-prefix 'PINGDEATH DROP: '
$iptables -A PINGOFDEATH -j DROP
$iptables -A INPUT -p icmp --icmp-type echo-request -j PINGOFDEATH

# 113番ポート(IDENT)へのアクセスには拒否応答
# メールサーバのレスポンス低下防止
$iptables -A INPUT -p tcp --dport 113 -j REJECT --reject-with tcp-reset

# }}}
# custom rules {{{

# ssh
$iptables -A INPUT -p tcp --dport  22 -j ACCEPT

# http, https
$iptables -A INPUT -p tcp --dport  80 -j ACCEPT
$iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# ftp
#$iptables -A INPUT -p tcp --sport  20 -j ACCEPT
#$iptables -A INPUT -p tcp --dport  21 -j ACCEPT
#$iptables -A INPUT -p tcp --dport 4000:4029 -j ACCEPT

# smtp
#$iptables -A INPUT -p tcp --dport  25 -j ACCEPT

# smtps
#$iptables -A INPUT -p tcp --dport 465 -j ACCEPT

# pop3
#$iptables -A INPUT -p tcp --dport 110 -j ACCEPT

# pop3s
#$iptables -A INPUT -p tcp --dport 995 -j ACCEPT

# imap
#$iptables -A INPUT -p tcp --dport 143 -j ACCEPT

# imaps
#$iptables -A INPUT -p tcp --dport 993 -j ACCEPT

# snmp
#$iptables -A INPUT -p tcp --dport 161 -j ACCEPT
#$iptables -A INPUT -p udp --dport 161 -j ACCEPT

# ldap
#$iptables -A INPUT -p tcp --dport 389 -j ACCEPT

# dns
$iptables -A INPUT -p udp --dport  53 -j ACCEPT
$iptables -A INPUT -p udp --sport  53 -j ACCEPT

# ntp
$iptables -A INPUT -p udp --dport 123 -j ACCEPT
$iptables -A INPUT -p udp --sport 123 -j ACCEPT

# ping
$iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT
$iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT

# }}}
# logging {{{

# ルールにマッチしなかったアクセスはログを記録して破棄
$iptables -A INPUT   -m limit --limit 1/s -j LOG $loglevel --log-prefix 'INPUT DROP: '
$iptables -A INPUT   -j DROP
$iptables -A FORWARD -m limit --limit 1/s -j LOG $loglevel --log-prefix 'FORWARD DROP: '
$iptables -A FORWARD -j DROP

# }}}
# start iptables {{{

# iptablesの設定を保存
/etc/rc.d/init.d/iptables save

# iptablesを起動
/etc/rc.d/init.d/iptables start

# }}}

echo
echo "Finished."
echo

exit 0
