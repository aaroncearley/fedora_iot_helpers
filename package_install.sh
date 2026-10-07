#!/bin/bash

# Error handling function
error_exit() {
    echo "Error: $1" >&2
    exit 1
}


# Install libvirt
echo "Installing libvirt components..."
# Add these to your installations:
rpm-ostree install -y \
    libvirt-daemon \
    qemu-kvm \
    bridge-utils \
    virt-top \
    virt-who \
    libvirt-client \
    libvirt-daemon-kvm \
    libvirt-daemon-lxc \
    libvirt-daemon-config-network \
    virt-install || error_exit "Failed to install libvirt"
echo "Finished installing libvirt"

read -p "Press key to continue.. " -n1 -s

# Install podman and related tools
echo "Installing podman components..."
rpm-ostree install -y \
    podman-compose \
    wireguard-tools || error_exit "Failed to install podman components"
echo "Finished installing podman"

read -p "Press key to continue.. " -n1 -s

# Install samba
echo "Installing samba components..."
rpm-ostree install -y \
    distrobox \
    nano \
    samba \
    samba-usershares || error_exit "Failed to install samba"
echo "Finished installing samba"

read -p "Press key to continue.. " -n1 -s

# Install cockpit
echo "Installing cockpit components..."
rpm-ostree install -y \
    cockpit \
    cockpit-files \
    cockpit-machines \
    cockpit-networkmanager \
    cockpit-ostree \
    cockpit-podman \
    cockpit-selinux \
    cockpit-storaged \
    cockpit-system || error_exit "Failed to install cockpit"
echo "Finished installing cockpit"

read -p "Press key to continue.. " -n1 -s


# echo "Installing bluetooth components..."
# rpm-ostree install -y \
#     bluez \
#     bluez-tools || error_exit "Failed to install bluetooth"
# echo "Finished installing bluetooth"
#
# read -p "Press key to continue.. " -n1 -s


# Install kubectl
echo "Installing kubeectl components..."
# Add these to your installations:
rpm-ostree install -y \
    kernel-modules-extra || error_exit "Failed to install kubectl"

echo "Finished installing kubeectl"

read -p "Press key to continue.. " -n1 -s

systemctl reboot



