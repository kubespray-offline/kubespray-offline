python3=python3
if [ -e /etc/redhat-release ]; then
    if [[ "$VERSION_ID" =~ ^7.* ]]; then
        if [ "$(getenforce)" == "Enforcing" ]; then
            echo "You must disable SELinux for RHEL7/CentOS7"
            exit 1
        fi
        python3=$(scl enable rh-python38 "which python3")
    #else
    #    python3=python3.8
    fi
fi
echo "python3 = $python3"
