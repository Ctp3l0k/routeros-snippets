# Просто чтобы не забыть, что так вообще можно. Особого смысла в применении не вижу.

/ip dns static
add forward-to=192.168.88.1 regexp=".*\\.network\\.lan" type=FWD
