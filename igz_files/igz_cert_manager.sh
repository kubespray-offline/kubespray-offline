#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 [check|backup|renew]"
    exit 1
}

# Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
    usage
fi

# Validate the argument
case $1 in
    check|backup|renew)
        # Run run_ansible.sh with the provided argument
        ./igz_run_ansible.sh -i inventory/igz/igz_inventory.ini igz_certs.yml --become --extra-vars=@igz_override.yml --extra-vars "do=$1"
        ;;
    *)
        # Invalid argument, display usage information
        usage
        ;;
esac
