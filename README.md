# azure-static-app


## VM script
``` bash
# SSH to NVA
sudo apt --assume-yes update
sudo apt --assume-yes upgrade
sudo apt --assume-yes install exabgp
sudo apt --assume-yes install haproxy
# Loopback IF
sudo ifconfig lo:9 9.9.9.9 netmask 255.255.255.255 up
# ExaBGP config
cat > exabgp-conf.ini << EOF
neighbor 172.16.159.4 {
	router-id 172.16.156.70;
	local-address 172.16.156.70;
	local-as 65010;
	peer-as 65515;
	static {
	route 9.9.9.9/32 next-hop 172.16.156.70 as-path [];
	}
}
neighbor 172.16.159.5 {
	router-id 172.16.156.70;
	local-address 172.16.156.70;
	local-as 65010;
	peer-as 65515;
	static {
	route 9.9.9.9/32 next-hop 172.16.156.70;
	}
}
EOF
## HAProxy config
sudo chmod 777 /etc/haproxy/haproxy.cfg
cat >> /etc/haproxy/haproxy.cfg << EOF
frontend http_front
        bind *:80
        stats uri /haproxy?stats
        default_backend http_back
backend http_back
        balance roundrobin
        server backend01 172.16.156.69:80 check
EOF

sudo systemctl restart haproxy

## Start ExaBGP
exabgp ./exabgp-conf.ini
```