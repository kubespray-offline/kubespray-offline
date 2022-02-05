# Set UTF-8 locale for pip.
# see https://github.com/pypa/pip/issues/10219
if locale -a | grep en_US.UTF-8 >/dev/null; then
    export LANG=en_US.UTF-8
elif locale -a | grep en_US.utf8 >/dev/null; then
    export LANG=en_US.utf8
elif locale -a | grep C.utf8 >/dev/null; then
    export LANG=C.utf8
else
    export LANG=C.UTF-8
fi
export LC_ALL=$LANG
