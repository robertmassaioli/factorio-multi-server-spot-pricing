#!/bin/bash

# Check if both arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <path_to_MySave.zip> <ec2_address>"
    exit 1
fi

# Get the file path and EC2 address from command line arguments
save_file="$1"
ec2_address="$2"

# Check if the file exists
if [ ! -f "$save_file" ]; then
    echo "File not found: $save_file"
    exit 1
fi

function scpu() {
    local ignore_known_hosts=0
    local accept_new=0
    local args=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --ignore-known-hosts)
                ignore_known_hosts=1
                shift
                ;;
            --accept-new)
                accept_new=1
                shift
                ;;
            *)
                args+=("$1")
                shift
                ;;
        esac
    done

    # Set SCP options based on flags
    local scp_opts=()
    if [[ $ignore_known_hosts -eq 1 ]]; then
        scp_opts+=(-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no)
    elif [[ $accept_new -eq 1 ]]; then
        scp_opts+=(-o StrictHostKeyChecking=accept-new)
    fi

    # Execute SCP command
    command scp "${scp_opts[@]}" "${args[@]}"
}

# Upload the save file to the EC2 instance
echo "Uploading save file to EC2 instance..."
scpu "$save_file" "ec2-user@$ec2_address:~/"

function sshu() {
    local ignore_known_hosts=0
    local accept_new=0
    local args=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --ignore-known-hosts)
                ignore_known_hosts=1
                shift
                ;;
            --accept-new)
                accept_new=1
                shift
                ;;
            *)
                args+=("$1")
                shift
                ;;
        esac
    done

    # Set SSH options based on flags
    local ssh_opts=()
    if [[ $ignore_known_hosts -eq 1 ]]; then
        ssh_opts+=(-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no)
    elif [[ $accept_new -eq 1 ]]; then
        ssh_opts+=(-o StrictHostKeyChecking=accept-new)
    fi

    # Execute SSH command
    command ssh "${ssh_opts[@]}" "${args[@]}"
}

# SSH into the EC2 instance and perform the required operations
sshu --ignore-known-hosts "ec2-user@$ec2_address" << EOF
    # Get the Factorio container ID
    container_id=\$(docker ps | grep factoriotools/factorio | awk '{print \$1}' | cut -c1-3)

    if [ -z "\$container_id" ]; then
        echo "Factorio container not found"
        exit 1
    fi

    echo "Factorio container ID: \$container_id"

    # Find the save directory
    savedir=\$(mount | grep nfs4 | cut -f3 -d ' ' | xargs -I {} echo "{}/saves")
    echo "Save directory: \$savedir"

    # Move the uploaded save to the right location
    sudo mv ~/$(basename "$save_file") \$savedir

    # Touch the save file to update its timestamp
    sudo touch \$savedir/$(basename "$save_file")

    # Force kill the Factorio docker container
    echo "Killing Factorio container..."
    docker kill \$container_id

    echo "Save file uploaded and container restarted. Please wait 30 seconds for the server to come back online."
EOF

echo "Script completed. The server should load your new save file when it restarts."