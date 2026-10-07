#!/bin/bash

# Function to display menu
show_menu() {
    echo "=========================================="
    echo "      K3s Cluster Setup Wizard"
    echo "=========================================="
    echo "Choose your setup option:"
    echo "1) Setup as FIRST SERVER NODE (Initial cluster)"
    echo "2) Join as SERVER NODE (Add to existing cluster)"
    echo "3) Join as AGENT NODE (Add to existing cluster)"
    echo "4) Uninstall K3s"
    echo "5) Exit"
    echo "=========================================="
}


get_token() {
    while true; do
        read -p "Enter the k3s cluster token: " token
        if [[ -n "$token" ]]; then
            echo "$token"
            return 0
        else
            echo "Token cannot be empty. Please try again."
        fi
    done
}


# Function to setup as first server node
setup_first_server() {
    echo "Setting up as FIRST SERVER NODE..."


    # Set up the first server node
    echo "Installing k3s as first server node..."

    # Create installation command with custom hostname
#
    install_cmd="curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.35.6+k3s1 sh -s - server --cluster-init"


    echo "Running: $install_cmd"
    eval "$install_cmd"


    # Wait for k3s to start
    sleep 10

    systemctl start k3s

    sleep 10


    # Get the token and save it
    if [ -f /etc/rancher/k3s/k3s.yaml ]; then
        echo "K3s server installed successfully!"
        echo "Token is stored in /var/lib/rancher/k3s/server/token"
        echo "Client config saved to /etc/rancher/k3s/k3s.yaml"

        # Show token for reference (optional)
        if [ -f /var/lib/rancher/k3s/server/token ]; then
            echo "Cluster token:"
            cat /var/lib/rancher/k3s/server/token
        fi
    else
        echo "Error: K3s installation failed!"
        exit 1
    fi
}

# Function to join as server node
setup_server_node() {
    echo "Setting up as SERVER NODE..."

    token=$(get_token)

    # Get hostname
    read -p "Enter hostname for master server (default: k3s-server-2): " hostname
    hostname=${hostname:-k3s-server-2}

    echo "Joining as server node to $hostname..."

    # Join command for additional server node
    join_cmd="curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.35.6+k3s1 K3S_TOKEN=$token sh -s - server --server https://$hostname:6443"

    echo "Running: $join_cmd"
    eval "$join_cmd"

      # Wait for k3s to start
    sleep 10

    systemctl start k3s

    sleep 10


    if [ $? -eq 0 ]; then
        echo "Successfully joined as server node!"
        echo "Connected to server: $hostname"
    else
        echo "Error: Failed to join as server node!"
        exit 1
    fi
}

# Function to join as agent node
setup_agent_node() {
    echo "Setting up as AGENT NODE..."

    token=$(get_token)

    # Get hostname
    read -p "Enter hostname for master server (default: k3s-agent-1): " hostname
    hostname=${hostname:-k3s-agent-1}

    echo "Joining as agent node to $hostname..."

    # Join command for agent node
    join_cmd="curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.35.6+k3s1 K3S_TOKEN=$token sh -s - agent --server https://$hostname:6443"

    echo "Running: $join_cmd"
    eval "$join_cmd"

      # Wait for k3s to start
    sleep 10

    systemctl start k3s-agent

    sleep 10


    if [ $? -eq 0 ]; then
        echo "Successfully joined as agent node!"
        echo "Connected to server: $hostname"
    else
        echo "Error: Failed to join as agent node!"
        exit 1
    fi
}

# Function to uninstall k3s
uninstall_k3s() {

    if systemctl is-active --quiet k3s; then
        echo "Uninstalling K3s..."
        /usr/local/bin/k3s-uninstall.sh
    fi

    if systemctl is-active --quiet k3s-agent; then
         echo "Uninstalling K3s agent..."
        /usr/local/bin/k3s-agent-uninstall.sh
    fi


    # Check if k3s is installed
    if ! command -v k3s &> /dev/null; then
        echo "K3s is not installed on this system."
        return 0
    fi

    # Ask for confirmation
    read -p "Are you sure you want to uninstall K3s? This will remove all k3s components (y/n): " confirm
    if [[ $confirm != [Yy] ]]; then
        echo "Uninstall cancelled."
        return 0
    fi

    echo "Stopping k3s services..."

    # Stop k3s services
    if systemctl is-active --quiet k3s; then
        systemctl stop k3s
    fi

    if systemctl is-active --quiet k3s-agent; then
        systemctl stop k3s-agent
    fi

    # Disable k3s services
    systemctl disable k3s 2>/dev/null || true
    systemctl disable k3s-agent 2>/dev/null || true

    echo "Removing k3s binaries and configurations..."




    # Remove k3s binary
    rm -f /usr/local/bin/k3s
    rm -f /usr/local/bin/k3s-killall.sh
    rm -f /usr/local/bin/k3s-install.sh

    # Remove k3s service files
    rm -rf /etc/systemd/system/k3s*
    rm -rf /lib/systemd/system/k3s*

    # Remove k3s data directories
    rm -rf /var/lib/rancher/k3s
    rm -rf /etc/rancher/k3s
    rm -rf /etc/rancher

    # Remove k3s configuration files
    rm -f /etc/k3s/config.yaml
    rm -f /etc/rancher/k3s/k3s.yaml

    # Clean up k3s user and group if they exist
    userdel -r k3s 2>/dev/null || true
    groupdel k3s 2>/dev/null || true

    # Reload systemd daemon
    systemctl daemon-reload

    echo "K3s has been uninstalled successfully!"
    echo ""
    echo "Note: Some system files or configurations might remain."
    echo "You may want to manually check:"
    echo "  - /etc/systemd/system/k3s*"
    echo "  - /var/lib/rancher/"
    echo "  - Any remaining k3s-related environment variables"

}

# Main execution
main() {
    echo "Welcome to K3s Cluster Setup Wizard"
    echo ""

    while true; do
        show_menu
        read -p "Enter your choice (1-5): " choice

        case $choice in
            1)
                setup_first_server
                break
                ;;
            2)
                setup_server_node
                break
                ;;
            3)
                setup_agent_node
                break
                ;;
            4)
                uninstall_k3s
                break
                ;;
            5)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo "Invalid choice. Please select 1-5."
                ;;
        esac
    done

    echo ""
    echo "Setup completed successfully!"
    echo "To verify your k3s installation:"
    echo "  sudo k3s kubectl get nodes"
    echo "  sudo k3s kubectl get pods -A"
}

# Run main function
main


echo "Finished installing kubectl"

read -p "Press key to continue.. " -n1 -s


systemctl reboot
