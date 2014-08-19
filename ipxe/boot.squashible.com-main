#!ipxe

:start
set boot_squashible_version 1
echo boot.squashible.com iPXE loader version 1

:dhcp  
dhcp || goto static
goto menu

:static
echo DHCP Server not found, enabling manual override:
imgfree
ifclose net0
echo -n IP: && read net0/ip
echo -n Subnet mask: && read net0/netmask
echo -n Gateway: && read net0/gateway
echo -n DNS: && read dns
ifopen net0
echo Attempting chainload of boot.squashible.com...
goto menu || goto failsafe

:menu
chain http://boot.squashible.com/boot.ipxe
goto boot

:failsafe
echo Attempt to load boot.squashible.com failed... restarting...
goto start

:boot
sanboot --no-describe --drive 0x80
