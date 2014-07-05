#!/sbin/sh

# Some variables to make life easier ;)
bb="/tmp/busybox"
del="/tmp/busybox rm -f"
deldir="/tmp/busybox rm -fR"
c1="/cache/dalvik-cache/system@app@"
c2="/cache/dalvik-cache/data@app@"
c3="/data/dalvik-cache/system@app@"
c4="/data/dalvik-cache/data@app@"

# A method that looks for the app's dex entry
# in all of the known locations, and deletes 
# it once found.
clrdex() {
	if [ -f $c1$1'@classes.dex' ]; then
		$del $c1$1'@classes.dex'
	fi
	
	if [ -f $c2$1'@classes.dex' ]; then
		$del $c2$1'@classes.dex'
	fi
	
	if [ -f $c3$1'@classes.dex' ]; then
		$del $c3$1'@classes.dex'
	fi
	
	if [ -f $c4$1'@classes.dex' ]; then
		$del $c4$1'@classes.dex'
	fi
}

# Allow ui_print from sh (thanks Chainfire!)
OUTFD=$(ps | grep -v "grep" | grep -o -E "update_binary(.*)" | cut -d " " -f 3);

[ $OUTFD != "" ] || OUTFD=$(ps | grep -v "grep" | grep -o -E "updater(.*)" | cut -d " " -f 3);

ui_print() {
  if [ $OUTFD != "" ]; then
    echo "ui_print ${1} " 1>&$OUTFD;
    echo "ui_print " 1>&$OUTFD;
  else
    echo "${1}";
  fi;
}

# Now we delete dex entries only for apps that
# had their classes.dex replaced.
# This is more efficient than deleting the whole
# cache, which will make boot time longer as Android
# will have to optimize all APKs present.

cd /sdcard/vrtheme/flags
for f in $(ls /sdcard/vrtheme/flags/*.apk)
do
	ui_print ""
	ui_print "$f's classes.dex was changed!"
	ui_print "Preparing Dalvik for this..."
	clrdex $f
done

# Finally we remove the vrtheme folder,
# but retain the backups. I mean, why do
# a backup if we're just going to delete
# the backup afterwards?
$bb mv /sdcard/vrtheme/backup /sdcard/vrtheme_backup
$deldir /sdcard/vrtheme

# Now, in case of a bootloop, the retained backups
# come in handy. We make a script in /system/xbin,
# and tell the user how to use it so that he/she
# may be able to restore the system to working condition.

# let's make a new method for appending lines to the script
mksc() {
	echo $1 >> /system/xbin/restore-vr
}

# exit if there is an existing script
[ -f /system/xbin/restore-vr ] && present=1 || present=0
if [ $present -eq "1" ]; then
	exit 0
fi

# make script
/tmp/busybox mount -o rw,remount /system
/tmp/busybox cp -f /tmp/busybox /system/xbin/busybox
chmod 0755 /system/xbin/busybox
/system/xbin/busybox --install -s /system/xbin
echo "#!/system/bin/sh" > /system/xbin/restore-vr
mksc "# Restore all VRTheme backups"
mksc ""
mksc "# Define a custom command for"
mksc "# executing commands as root"
mksc 'sudo="su -c '$@'"'
mksc ""
mksc "# Mount as rw"
mksc '$sudo mount -o rw,remount /system'
mksc '$sudo mount -o rw,remount /data'
mksc '$sudo mount -o rw,remount /preload'
mksc '$sudo mount -o rw,remount /cache'
mksc ""
mksc "# Look for the backups. /sdcard"
mksc "# points to different locations on every"
mksc "# device"
mksc "dm=/data/media/vrtheme_backup"
mksc "dm0=/data/media/0/vrtheme_backup"
mksc "ss0=/storage/sdcard0/vrtheme_backup"
mksc "se0=/storage/emulated/0/vrtheme_backup"
mksc "sd0=/storage/extSdCard/vrtheme_backup"
mksc "sel=/storage/emulated/legacy/vrtheme_backup"
mksc "ss1=/storage/sdcard1/vrtheme_backup"
mksc "norm=/sdcard/vrtheme_backup"
mksc '[ -d $dm ] && loc=$dm'
mksc '[ -d $dm0 ] && loc=$dm0'
mksc '[ -d $ss0 ] && loc=$ss0'
mksc '[ -d $se0 ] && loc=$se0'
mksc '[ -d $sd0 ] && loc=$sd0'
mksc '[ -d $sel ] && loc=$sel'
mksc '[ -d $ss1 ] && loc=$ss1'
mksc '[ -d $norm ] && loc=$norm'
mksc ""
mksc "# Restore the backup"
mksc '$sudo stop'
mksc '$sudo busybox cp $loc/system/* /system/'
mksc '$sudo busybox cp $loc/data/* /data/'
mksc '$sudo busybox cp $loc/preload/* /preload/'
mksc ""
mksc "# Wipe the whole Dalvik cache, to be sure"
mksc '$sudo busybox rm -f /data/dalvik-cache/*'
mksc '$sudo busybox rm -f /cache/dalvik-cache/*'
mksc ""
mksc "# Reboot"
mksc '$sudo reboot'
chmod 0755 /system/xbin/restore-vr

ui_print ""
ui_print "************************"
ui_print "In case of bootloop, connect your"
ui_print "phone in ADB and execute"
ui_print "/system/xbin/restore-vr"
ui_print "thru adb shell, or make your own"
ui_print "flashable zip and include this line"
ui_print "in updater-script:"
ui_print 'run_program("/system/xbin/restore-vr");'
ui_print "************************"
exit 0