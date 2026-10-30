# 2026-10-30 18:41:17 by RouterOS 7.23.7
# system id = axF1O7KyPWL
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
set [ find default-name=ether5 ] disable-running-check=no
set [ find default-name=ether6 ] disable-running-check=no
/user group
add name=nivel0 policy=local,!telnet,!ssh,!ftp,!reboot,!read,!write,!policy,!test,!winbox,!password,!web,!sniff,!sensitive,!api,!romon,!rest-api
add name=nivel5 policy=local,read,test,!telnet,!ssh,!ftp,!reboot,!write,!policy,!winbox,!password,!web,!sniff,!sensitive,!api,!romon,!rest-api
add name=nivel10 policy=local,read,write,test,!telnet,!ssh,!ftp,!reboot,!policy,!winbox,!password,!web,!sniff,!sensitive,!api,!romon,!rest-api
add name=sin-acceso
add name=gestion-local policy=local,ssh,reboot,read,write,policy,test,password,sensitive,!telnet,!ftp,!winbox,!web,!sniff,!api,!romon,!rest-api
/ip address
add address=10.24.96.1/24 comment=LAN-AAA interface=ether2 network=10.24.96.0
/ip dhcp-client
add interface=ether1 name=client1 use-peer-dns=no
/ip dns
set servers=1.1.1.1,8.8.8.8
/ip firewall nat
add action=masquerade chain=srcnat comment=Internet-LAB out-interface=ether1 src-address=10.24.96.0/24
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
add address=10.24.96.138 comment=NPS-AAA require-message-auth=no service=login src-address=10.24.96.1 timeout=3s
/system identity
set name=R1-AAA
/system logging
add prefix=AAA-RADIUS topics=radius,!packet
/tool mac-server
set allowed-interface-list=none
/tool mac-server mac-winbox
set allowed-interface-list=none
/user aaa
set default-group=sin-acceso exclude-groups=full,read,write,gestion-local interim-update=1m use-radius=yes
