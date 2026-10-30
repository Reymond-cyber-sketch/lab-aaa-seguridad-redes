# 2026-10-30 19:04:42 by RouterOS 7.23.7
# system id = mc39KjE/XsH
#
/interface bridge
add name=BR-AAA
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
set [ find default-name=ether5 ] disable-running-check=no
set [ find default-name=ether6 ] disable-running-check=no
/user group
add name=nivel0 policy="local,!telnet,!ssh,!ftp,!reboot,!read,!write,!policy,!test,!winbox,!password,!web,!sniff,!sensi\
    tive,!api,!romon,!rest-api"
add name=nivel5 policy="local,read,test,!telnet,!ssh,!ftp,!reboot,!write,!policy,!winbox,!password,!web,!sniff,!sensiti\
    ve,!api,!romon,!rest-api"
add name=nivel10 policy="local,read,write,test,!telnet,!ssh,!ftp,!reboot,!policy,!winbox,!password,!web,!sniff,!sensiti\
    ve,!api,!romon,!rest-api"
add name=sin-acceso
add name=gestion-local policy=\
    local,ssh,reboot,read,write,policy,test,password,sensitive,!telnet,!ftp,!winbox,!web,!sniff,!api,!romon,!rest-api
/interface bridge port
add bridge=BR-AAA interface=ether1
add bridge=BR-AAA interface=ether2
add bridge=BR-AAA interface=ether3
/ip address
add address=10.24.96.2/24 comment=Gestion-AAA interface=BR-AAA network=10.24.96.0
/ip dhcp-client
add disabled=yes interface=ether1 name=client1
/ip dns
set servers=1.1.1.1,8.8.8.8
/ip route
add dst-address=0.0.0.0/0 gateway=10.24.96.1
/ip service
set ftp disabled=yes
set ssh address=10.24.96.0/24
set telnet disabled=yes
set www disabled=yes
set winbox disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/ip ssh
set strong-crypto=yes
/radius
add address=10.24.96.138 comment=NPS-AAA require-message-auth=no service=login src-address=10.24.96.2 timeout=3s
/system identity
set name=SW1-AAA
/system logging
add prefix=AAA-RADIUS topics=radius,!packet
/tool mac-server
set allowed-interface-list=none
/tool mac-server mac-winbox
set allowed-interface-list=none
/user aaa
set default-group=sin-acceso exclude-groups=full,read,write,gestion-local interim-update=1m use-radius=yes
