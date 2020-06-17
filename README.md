Infra
=====

# Missing

## Setting up OpenVPN server

Install with https://github.com/angristan/openvpn-install/

Then add this to `/etc/ufw/before.rules` to allow traffic from VPN into private network

```
# route openvpn to LAN
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s 10.8.0.0/8 -o ens4 -j MASQUERADE
COMMIT
```

Reference: https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-18-04#step-6-%E2%80%94-adjusting-the-server-networking-configuration
