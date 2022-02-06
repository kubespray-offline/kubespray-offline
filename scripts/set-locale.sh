# Set UTF-8 locale for pip.
# see https://github.com/pypa/pip/issues/10219
export LANG=C.UTF-8
for i in en_US.UTF-8 en_US.utf8 C.utf8; do
    if locale -a | grep $i >/dev/null; then
        export LANG=$i
        break
    fi
done
export LC_ALL=$LANG
