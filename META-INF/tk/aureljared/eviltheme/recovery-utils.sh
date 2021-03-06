# Eviltheme by Jared Dantis (@aureljared)
# Licensed under GPL v3
# https://github.com/aureljared/eviltheme
OUTFD=/proc/self/fd/$2

# Embedded mode support (from @osm0sis)
readlink /proc/$$/fd/$2 2>/dev/null | grep /tmp >/dev/null;
if [ "$?" -eq "0" ]; then
    # rerouted to log file, so suppress recovery ui commands
    OUTFD=/proc/self/fd/0
    # try to find the actual fd (pipe with parent updater likely started as 'update-binary 3 fd zipfile')
    for FD in $(ls /proc/$$/fd); do
        readlink /proc/$$/fd/$FD 2>/dev/null | grep pipe >/dev/null
        if [ "$?" -eq "0" ]; then
            ps | grep " 3 $FD " | grep -v grep >/dev/null
            if [ "$?" -eq "0" ]; then
                OUTFD=/proc/self/fd/$FD
                break
            fi
        fi
    done
fi

# Detect dual /system partitions
[ -d "/system/system" ] && ROOT="/system" || ROOT=

# Print to recovery UI
#   ui_print "Hello!"
ui_print() { echo "ui_print ${1} " >> $OUTFD; }

# Set progress bar value
#   set_progress 0.25     <= set progress bar to 25%
set_progress() { echo "set_progress ${1}" >> $OUTFD; }

# Gradually increment progress bar value
#   progress 0.25 10      <= add 25% to progress bar over a period of 10 seconds
progress() { echo "progress ${1} ${2}" >> $OUTFD; }

# Set file permissions (and SELinux context)
#   set_perm(uid, gid, mode, file, <context>)
set_perm() {
    chown $1:$2 $4
    chmod $3 $4
    if [ ! -z $5 ]; then
        chcon $5 $4
    else
        chcon 'u:object_r:system_file:s0' $1
    fi
}

# Set directory permissions (and SELinux contexts) recursively
#   set_perm_recursive(uid, gid, folderMode, fileMode, dir, <context>)
set_perm_recursive() {
    find $5 -type d 2>/dev/null | while read dir; do
        set_perm $1 $2 $3 $dir $6
    done
    find $5 -type f 2>/dev/null | while read file; do
        set_perm $1 $2 $4 $file $6
    done
}
