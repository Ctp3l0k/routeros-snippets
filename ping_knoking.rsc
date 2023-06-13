# По хорошему, надо делать несколько последовательных пингов разного размера.
# И еще хорошо бы банить тех, кто не тот пинг присылает.

/ip firewall filter
add action=accept chain=input comment=\
    "(2) Allow only sources of ping -l 1420  to 22, 80 and 8291 ports" \
    dst-port=22,80,8291 in-interface-list=WAN protocol=tcp src-address-list=\
    access-list
add action=add-src-to-address-list address-list=access-list \
    address-list-timeout=5m chain=input in-interface-list=WAN packet-size=\
    1448 protocol=icmp
