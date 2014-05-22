#!/bin/sh
#set -x

domain=${1:-"server"}

key_password="sslpassphrase"
key_filename="server.key"
csr_filename="server.csr"
crt_filename="server.crt"
nok_filename="server.nokey"
days=3650
timeout=1

country_name="JP"
state_of_province="Tokyo"
locality_name="Shibuya-ku"
organization_name="Example, Inc."
organization_unit="dummy"
common_name="*.${domain}"
email="root@localhost"

# usage {{{

function usage()
{
  cat << _EOT_

===========================================================================
Usage:

  `basename $0` [ domain ]


Detail:

  if [ example.jp ] is specified as your domain,
  the certificate is generated for wildcard domain [ *.example.jp ].

===========================================================================

_EOT_
}

# }}}
# errmsg_trap {{{

function errmsg_trap()
{
  cat << _EOT_

===========================================================================
_EOT_

  echo -e $msg

  cat << _EOT_
===========================================================================

_EOT_
}

# }}}

# trap
trap 'msg="Signal trapped: abort"; errmsg_trap; exit 1' 1 2 3 15

if [ ! "$domain" ]; then
  usage
  exit 0
fi

# sslkey {{{

# generate sslkey
expect -c "`cat <<_EOT_
  set timeout $timeout
  spawn openssl genrsa -rand /var/log/messages -aes256 -out www.example.com.key 2048 54002 semi-random bytes loaded
  expect "Enter pass phrase for www.example.com.key:" ;
  send "${key_password}\n" ;

  expect "Verifying - Enter pass phrase for www.example.com.key:" ;
  send "${key_password}\n" ;
  interact
_EOT_`"

# rename sslkey
mv www.example.com.key $key_filename

# check sslkey file
expect -c "`cat <<_EOT_
  set timeout $timeout
  spawn openssl rsa -noout -text -in $key_filename
  expect "Enter pass phrase for ${key_filename}:" ;
  send "${key_password}\n" ;
  interact
_EOT_`"

# }}}
# sslcsr {{{

# generate sslcsr file
expect -c "`cat <<_EOT_
  set timeout $timeout
  spawn openssl req -new -key $key_filename -out $csr_filename
  expect "Enter pass phrase for ${key_filename}:" ;
  send "${key_password}\n" ;

  expect "Country Name (2 letter code) \[XX\]:" ;
  send "${country_name}\n" ;

  expect "State or Province Name (full name) \[\]:" ;
  send "${state_of_province}\n" ;

  expect "Locality Name (eg, city) \[Default City\]:" ;
  send "${locality_name}\n" ;

  expect "Organization Name (eg, company) \[Default Company Ltd\]:" ;
  send "${organization_name}\n" ;

  expect "Organizational Unit Name (eg, section) \[\]:" ;
  send "${organization_unit}\n" ;

  expect "Common Name (eg, your name or your server's hostname) \[\]:" ;
  send "${common_name}\n" ;

  expect "Email Address \[\]:" ;
  send "${email}\n"

  expect "A challenge password \[\]:" ;
  send "\n"

  expect "An optional company name \[\]:" ;
  send "\n"
  interact
_EOT_`"

# check sslcsr file
openssl req -noout -text -in $csr_filename

# }}}
# sslcrt {{{

# generate sslcrt file
expect -c "`cat <<_EOT_
  set timeout $timeout
  spawn openssl x509 -in $csr_filename -out $crt_filename -req -signkey $key_filename -days $days
  expect "Enter pass phrase for ${key_filename}:" ;
  send "${key_password}\n" ;
  interact
_EOT_`"

# check sslcrt file
openssl x509 -noout -text -in $crt_filename

# }}}
# nokey {{{

# generate sslkey file w/out password
expect -c "`cat <<_EOT_
  set timeout $timeout
  spawn openssl rsa -in $key_filename -out $nok_filename
  expect "Enter pass phrase for ${key_filename}:"
  send "${key_password}\n"
  interact
_EOT_`"

# check sslkey file w/out password
openssl rsa -noout -text -in $nok_filename

# }}}

exit 0
