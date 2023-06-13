# В данном случае для трех провайдеров.
# Маршруты для локальной сети по хорошему не нужны, но у меня почему-то без них не работало.
# Возможно, это из-за того, что я настроил неправильно и вместо "connection-state=new" в mangle нужно ставить "packet-mark=no-mark".
# А еще тут же рекурсивные маршруты.

/ip firewall mangle
add action=mark-connection chain=prerouting comment=\
    "(9) Multi-WAN marking" \
    connection-state=new in-interface=ether1 new-connection-mark=con-WAN1 \
    passthrough=yes
add action=mark-connection chain=prerouting connection-state=new \
    in-interface=ether2 new-connection-mark=con-WAN2 passthrough=yes
add action=mark-connection chain=prerouting connection-state=new \
    in-interface=ether3 new-connection-mark=con-WAN3 passthrough=yes
add action=mark-routing chain=prerouting connection-mark=con-WAN1 \
    in-interface-list=!WAN new-routing-mark=WAN1 passthrough=yes
add action=mark-routing chain=prerouting connection-mark=con-WAN2 \
    in-interface-list=!WAN new-routing-mark=WAN2 passthrough=yes
add action=mark-routing chain=prerouting connection-mark=con-WAN3 \
    in-interface-list=!WAN new-routing-mark=WAN3 passthrough=yes
add action=mark-routing chain=output connection-mark=con-WAN1 \
    new-routing-mark=WAN1 passthrough=yes
add action=mark-routing chain=output connection-mark=con-WAN2 \
    new-routing-mark=WAN2 passthrough=yes
add action=mark-routing chain=output connection-mark=con-WAN3 \
    new-routing-mark=WAN3 passthrough=yes

/ip route
add check-gateway=ping comment="WAN1 marked" distance=1 gateway=444.444.444.444 \
    routing-mark=WAN1
add check-gateway=ping comment="WAN2 marked" distance=1 gateway=555.555.555.555 \
    routing-mark=WAN2
add check-gateway=ping comment="WAN3 marked" distance=1 gateway=666.666.666.666 \
    routing-mark=WAN3
add check-gateway=ping comment="WAN1 recursive" distance=1 gateway=1.1.1.1
add check-gateway=ping comment="WAN2 recursive" distance=2 gateway=9.9.9.9
add check-gateway=ping comment="WAN3 recursive" distance=3 gateway=8.8.8.8
add check-gateway=ping comment="WAN1 non-recursive" distance=4 gateway=\
    444.444.444.444
add check-gateway=ping comment="WAN2 non-recusive" distance=5 gateway=\
    555.555.555.555
add check-gateway=ping comment="WAN3 non-recusive" distance=6 gateway=\
    666.666.666.666
add check-gateway=ping comment="For recursive WAN1" distance=1 dst-address=\
    1.1.1.1/32 gateway=444.444.444.444 scope=10
add check-gateway=ping comment="For recursive WAN2" distance=1 dst-address=\
    9.9.9.9/32 gateway=555.555.555.555 scope=10
add check-gateway=ping comment="For recursive WAN3" distance=1 dst-address=\
    8.8.8.8/32 gateway=666.666.666.666 scope=10
# Да, вот это те самые лишние маршруты, которые не нужны, если mangle исправить.
# Я бы их убрал и конфиг исправил, но мне не на чем сейчас проверять, как оно будет работать.
add comment="LAN for routed" distance=1 dst-address=192.168.88.0/24 gateway=\
    bridge1 routing-mark=WAN1
add comment="LAN for routed" distance=1 dst-address=192.168.88.0/24 gateway=\
    bridge1 routing-mark=WAN2
add comment="LAN for routed" distance=1 dst-address=192.168.88.0/24 gateway=\
    bridge1 routing-mark=WAN3

/ip route rule
add action=lookup-only-in-table comment="WAN1 only via WAN1" src-address=\
    1111.1111.1111.1111/32 table=WAN1
add action=lookup-only-in-table comment="WAN2 only via WAN2" src-address=\
    2222.2222.2222.2222/32 table=WAN2
add action=lookup-only-in-table comment="WAN3 only via WAN3" src-address=\
    333.333.333.333/32 table=WAN3
