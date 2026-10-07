# Configure firewalld for libvirt
# TCP	6443	Agents	Servers	K3s supervisor and Kubernetes API Server
# TCP	6443	All nodes	All nodes	Required only for embedded distributed registry (Spegel)
firewall-cmd --permanent --add-port=6443/tcp

#TCP	2379-2380	Servers	Servers	Required only for HA with embedded etcd
firewall-cmd --permanent --add-port=2379/tcp
firewall-cmd --permanent --add-port=2380/tcp

#TCP	5001	All nodes	All nodes	Required only for embedded distributed registry (Spegel)
firewall-cmd --permanent --add-port=5001/tcp

#TCP	10250	All nodes	All nodes	Kubelet metrics and API
firewall-cmd --permanent --add-port=10250/tcp


#UDP	8472	All nodes	All nodes	Required only for Flannel VXLAN
firewall-cmd --permanent --add-port=8472/udp


#UDP	51820	All nodes	All nodes	Required only for Flannel Wireguard with IPv4
firewall-cmd --permanent --add-port=51820/udp

#UDP	51821	All nodes	All nodes	Required only for Flannel Wireguard with IPv6
firewall-cmd --permanent --add-port=51821/udp

firewall-cmd --permanent --zone=trusted --add-source=10.40.0.0/16 #pods
firewall-cmd --permanent --zone=trusted --add-source=10.42.0.0/16 #pods
firewall-cmd --permanent --zone=trusted --add-source=10.43.0.0/16 #services


firewall-cmd --permanent --add-service=cockpit || error_exit "Failed to configure firewalld:cockpit"
firewall-cmd --permanent --add-service=libvirt || error_exit "Failed to configure firewalld:libvirt"
firewall-cmd --reload || error_exit "Failed to reload firewalld"

systemctl reboot
