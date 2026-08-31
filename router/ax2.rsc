# MikroTik hAP ax2 — full config
#
# Apply with (after uploading this file to Files):
#   /system reset-configuration no-defaults=yes skip-backup=yes run-after-reset=ax2.rsc

# --- settings -----------------------------------------------------------------

:global adminPassword "CHANGE-ME-ADMIN-PASSWORD"
:global wifiSsid "CHANGE-ME-WIFI-SSID"
:global wifiPassword "CHANGE-ME-WIFI-PASSWORD"
:global country "Poland"
:global timeZone "Europe/Warsaw"

# --- identity, password, clock ------------------------------------------------

/system identity
set name=ax2

/user
set admin password=$adminPassword

/system clock
set time-zone-name=$timeZone

/system ntp client
set enabled=yes mode=unicast

/system ntp client servers
add address=0.pool.ntp.org
add address=1.pool.ntp.org

# --- bridge and interface lists -----------------------------------------------

# admin-mac pinned to ether2 so the bridge MAC never shifts between member ports
/interface bridge
add name=bridge comment="LAN" auto-mac=no \
    admin-mac=[/interface ethernet get [/interface ethernet find default-name=ether2] mac-address]

/interface bridge port
add bridge=bridge interface=ether2
add bridge=bridge interface=ether3
add bridge=bridge interface=ether4
add bridge=bridge interface=ether5

/interface list
add name=WAN
add name=LAN

/interface list member
add list=WAN interface=ether1
add list=LAN interface=bridge

# --- addressing and default route ---------------------------------------------

/ip address
add address=192.168.88.1/24 interface=bridge comment="LAN"
add address=192.168.100.254/24 interface=ether1 comment="transit to ONT"

/ip route
add dst-address=0.0.0.0/0 gateway=192.168.100.1 comment="default via ONT"

# --- router's own DNS ---------------------------------------------------------

/ip dns
set servers=1.1.1.1,1.0.0.1 allow-remote-requests=no

# --- DHCP server --------------------------------------------------------------

/ip pool
add name=lan ranges=192.168.88.10-192.168.88.254

/ip dhcp-server
add name=lan interface=bridge address-pool=lan lease-time=1d

/ip dhcp-server network
add address=192.168.88.0/24 gateway=192.168.88.1 dns-server=192.168.88.2,192.168.88.3

# Static reservations go here, e.g.:
# /ip dhcp-server lease
# add server=lan address=192.168.88.4 mac-address=AA:BB:CC:DD:EE:FF comment="deco-1"

# --- NAT ----------------------------------------------------------------------

/ip firewall nat
add action=masquerade chain=srcnat comment="defconf: masquerade" ipsec-policy=out,none out-interface-list=WAN

# --- firewall -----------------------------------------------------------------

/ip firewall filter
add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=accept chain=input comment="defconf: accept to local loopback (for CAPsMAN)" src-address=127.0.0.1 dst-address=127.0.0.1 in-interface=lo
add action=drop chain=input comment="defconf: drop all not coming from LAN" in-interface-list=!LAN
add action=accept chain=forward comment="defconf: accept in ipsec policy" ipsec-policy=in,ipsec
add action=accept chain=forward comment="defconf: accept out ipsec policy" ipsec-policy=out,ipsec
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-state=established,related
add action=accept chain=forward comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=drop chain=forward comment="defconf: drop all from WAN not DSTNATed" connection-nat-state=!dstnat in-interface-list=WAN

# --- IPv6 off -----------------------------------------------------------------

/ipv6 settings
set disable-ipv6=yes

# --- service hardening --------------------------------------------------------

/ip service
set telnet disabled=yes
set ftp disabled=yes
set api disabled=yes
set api-ssl disabled=yes
set www-ssl disabled=yes
set www disabled=no
set ssh disabled=no
set winbox disabled=no

/tool mac-server
set allowed-interface-list=LAN

/tool mac-server mac-winbox
set allowed-interface-list=LAN

/tool bandwidth-server
set enabled=no

/ip neighbor discovery-settings
set discover-interface-list=LAN

# --- Wi-Fi: configured, then disabled ----------------------------
# Small delay so the radios are enumerated before we touch them.

:delay 5s

/interface bridge port
add bridge=bridge interface=wifi1
add bridge=bridge interface=wifi2

/interface wifi
set [find default-name=wifi1] configuration.mode=ap configuration.country=$country configuration.ssid=$wifiSsid
set [find default-name=wifi1] channel.band=5ghz-ax channel.width=20/40/80mhz channel.skip-dfs-channels=10min-cac
set [find default-name=wifi1] security.authentication-types=wpa2-psk,wpa3-psk security.passphrase=$wifiPassword security.ft=yes security.ft-over-ds=yes
set [find default-name=wifi1] disabled=yes
set [find default-name=wifi2] configuration.mode=ap configuration.country=$country configuration.ssid=$wifiSsid
set [find default-name=wifi2] channel.band=2ghz-ax channel.width=20/40mhz channel.skip-dfs-channels=10min-cac
set [find default-name=wifi2] security.authentication-types=wpa2-psk,wpa3-psk security.passphrase=$wifiPassword security.ft=yes security.ft-over-ds=yes
set [find default-name=wifi2] disabled=yes

# --- done ---------------------------------------------------------------------

:set adminPassword
:set wifiSsid
:set wifiPassword
:set country
:set timeZone

:log info "ax2.rsc applied"
