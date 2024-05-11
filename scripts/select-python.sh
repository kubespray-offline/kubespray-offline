# Now always use specific python version
python3=python3.11

if [ -e /etc/redhat-release ]; then
    if [[ "$VERSION_ID" =~ ^7.* ]]; then
        echo "FATAL: RHEL/CentOS 7 is not supported anymore"
        exit 1
        #if [ "$(getenforce)" == "Enforcing" ]; then
        #    echo "You must disable SELinux for RHEL7/CentOS7"
        #    exit 1
        #fi
        #python3=$(scl enable rh-python38 "which python3")
    fi
else
    #if [[ "$VERSION_ID" =~ ^20 ]]; then
    #    python3=python3.11
    #fi
    :
fi
echo "python3 = $python3"
