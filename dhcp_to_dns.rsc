# Автор не я, а некий Pessoft. Скрипт взят из его блога:
# https://blog.pessoft.com/2019/09/06/mikrotik-script-automatic-dns-records-from-dhcp-leases/
# Сохраняю себе в гит, потому что иначе точно потеряю.

# When "1" all DNS entries with IP address of DHCP lease are removed
:local dnsRemoveAllByIp "1"
# When "1" all DNS entries with hostname of DHCP lease are removed
:local dnsRemoveAllByName "1"
# When "1" addition and removal of DNS entries is always done also for non-FQDN hostname
:local dnsAlwaysNonfqdn "1"
# DNS domain to add after DHCP client hostname
:local dnsDomain "dynamic.example.local"
# DNS TTL to set for DNS entries
:local dnsTtl "00:15:00"
# Source of DHCP client hostname, can be "lease-hostname" or any other lease attribute, like "host-name" or "comment"
:local leaseClientHostnameSource "lease-hostname"

:local leaseComment "dhcp-lease-script_$leaseServerName_$leaseClientHostnameSource"
:local leaseClientHostname
:if ($leaseClientHostnameSource = "lease-hostname") do={
  :set leaseClientHostname $"lease-hostname"
} else={
  :set leaseClientHostname ([:pick \
    [/ip dhcp-server lease print as-value where server="$leaseServerName" address="$leaseActIP" mac-address="$leaseActMAC"] \
    0]->"$leaseClientHostnameSource")
}
:local leaseClientHostnames "$leaseClientHostname"
:if ([:len [$dnsDomain]] > 0) do={
  :if ($dnsAlwaysNonfqdn = "1") do={
    :set leaseClientHostnames "$leaseClientHostname.$dnsDomain,$leaseClientHostname"
  } else={
    :set leaseClientHostnames "$leaseClientHostname.$dnsDomain"
  }
}
:if ($dnsRemoveAllByIp = "1") do={
  /ip dns static remove [/ip dns static find comment="$leaseComment" and address="$leaseActIP"]
}
:foreach h in=[:toarray value="$leaseClientHostnames"] do={
  :if ($dnsRemoveAllByName = "1") do={
    /ip dns static remove [/ip dns static find comment="$leaseComment" and name="$h"]
  }
  /ip dns static remove [/ip dns static find comment="$leaseComment" and address="$leaseActIP" and name="$h"]
  :if ($leaseBound = "1") do={
    :delay 1
    /ip dns static add comment="$leaseComment" address="$leaseActIP" name="$h" ttl="$dnsTtl"
  }
}
