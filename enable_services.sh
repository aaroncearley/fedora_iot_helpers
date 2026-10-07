echo "Starting services..."
#systemctl enable --now bluetooth.service || error_exit "Failed to start bluetooth"
systemctl enable --now cockpit.socket || error_exit "Failed to start cockpit"
systemctl enable --now libvirtd || error_exit "Failed to start libvirtd"
systemctl enable --now libvirtd.socket || error_exit "Failed to start libvirtd.socket"
systemctl enable --now virtlogd || error_exit "Failed to start virtlogd"
systemctl enable --now firewalld || error_exit "Failed to start firewalld"
systemctl enable --now podman.socket || error_exit "Failed to start podman.socket"

systemctl reboot
