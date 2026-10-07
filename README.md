# Fedora IoT Helpers

Helper scripts for setting up and maintaining a Fedora IoT system after installation.

This repository contains a few bash utilities for preparing a Fedora-based host for virtualization, container workloads, firewall access, and a K3s cluster.

## Included scripts

### `package_install.sh`

A Fedora IoT installation script that uses `rpm-ostree install` to add common packages required for a lightweight edge or homelab environment.

What it installs:
- `libvirt` and virtualization tooling
- `podman-compose` and `wireguard-tools`
- `distrobox`, `nano`, `samba`, and Samba usershares
- `cockpit` and related cockpit plugins
- `kernel-modules-extra`

This script is intended for a Fedora IoT system that uses `rpm-ostree` and ends with a reboot.

### `package_install_dnf.sh`

The same package installation flow as `package_install.sh`, but using `dnf` instead of `rpm-ostree`.

This version is useful for a standard Fedora install, or for a Fedora IoT system where `dnf` is the preferred package manager. It installs the same categories of software and reboots at the end.

### `enable_services.sh`

Enables and starts the core background services needed for virtualization and firewall management.

Enabled services:
- `cockpit.socket`
- `libvirtd`
- `libvirtd.socket`
- `virtlogd`
- `firewalld`
- `podman.socket`

This script is a simple service bootstrap step after installing the required packages.

### `firewall_update.sh`

Configures `firewalld` for Kubernetes and virtualization use. It adds the necessary TCP/UDP ports for a K3s environment, including:
- K3s API and registry traffic
- kubelet and etcd-related ports
- Flannel VXLAN and WireGuard traffic

It also adds trusted sources for pod and service networks and enables the `cockpit` and `libvirt` firewalld services before reloading the firewall rules and rebooting.

This script is especially useful when deploying K3s on a Fedora host that will run workloads and services with pod networking.

### `k3s_install.sh`

An interactive K3s setup wizard.

The script presents a menu with these choices:
1. Set up as the first server node in a new cluster
2. Join as a server node to an existing cluster
3. Join as an agent node to an existing cluster
4. Uninstall K3s
5. Exit

It uses the `get.k3s.io` installation script and pins the K3s version to `v1.35.6+k3s1`.

This script is useful for quickly standing up a small K3s cluster on Fedora IoT hosts without manually assembling each install command.

## Typical workflow

A common sequence is:

1. Install base packages with `package_install.sh` or `package_install_dnf.sh`
2. Enable required services with `enable_services.sh`
3. Update firewall rules with `firewall_update.sh`
4. Bootstrap or join a K3s cluster with `k3s_install.sh`

## Notes

- These scripts are intentionally focused and simple; they are not general-purpose installers.
- Some scripts reboot the machine automatically after completing setup.
- Run commands with `sudo` when appropriate, especially for systemd and firewall configuration.
- Review each script before executing it on a production system.

## Example usage

```bash
chmod +x *.sh
sudo ./package_install.sh
sudo ./enable_services.sh
sudo ./firewall_update.sh
sudo ./k3s_install.sh
```

## License

This project is distributed under the license included in the repository (`LICENSE`).
