#!/system/bin/sh
# Restore all VRTheme backups

# Define a custom command for executing commands as root
sudo=su -c '$@'

# Mount as rw
$sudo mount -o rw,remount /system
$sudo mount -o rw,remount /data
$sudo mount -o rw,remount /preload
$sudo mount -o rw,remount /cache

# Look for the backups. /sdcard points to different locations on every device
dm=/data/media/vrtheme_backup
dm0=/data/media/0/vrtheme_backup
ss0=/storage/sdcard0/vrtheme_backup
se0=/storage/emulated/0/vrtheme_backup
sd0=/storage/extSdCard/vrtheme_backup
sel=/storage/emulated/legacy/vrtheme_backup
ss1=/storage/sdcard1/vrtheme_backup
norm=/sdcard/vrtheme_backup

[ -d $dm ] && loc=$dm
[ -d $dm0 ] && loc=$dm0
[ -d $ss0 ] && loc=$ss0
[ -d $se0 ] && loc=$se0
[ -d $sd0 ] && loc=$sd0
[ -d $sel ] && loc=$sel
[ -d $ss1 ] && loc=$ss1
[ -d $norm ] && loc=$norm

# Restore the backup
$sudo stop
$sudo busybox cp $loc/system/* /system/
$sudo busybox cp $loc/data/* /data/
$sudo busybox cp $loc/preload/* /preload/

# Wipe the whole Dalvik cache, to be sure
$sudo busybox rm -f /data/dalvik-cache/*
$sudo busybox rm -f /cache/dalvik-cache/*

# Reboot
$sudo reboot