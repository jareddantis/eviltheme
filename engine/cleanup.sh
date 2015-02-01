#!/sbin/sh

# Some variables to make life easier ;)
bb="/tmp/busybox"
del="/tmp/busybox rm -f"
deldir="/tmp/busybox rm -fR"
c1="/cache/dalvik-cache/system@app@"
c2="/cache/dalvik-cache/data@app@"
c3="/data/dalvik-cache/system@app@"
c4="/data/dalvik-cache/data@app@"

# A method that looks for the app's dex entry in all of the known locations.
# and deletes it once found.
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

# Now we delete dex entries only for apps that had their classes.dex replaced.
# This is more efficient than deleting the whole cache, which will make boot time longer as Android
# will have to optimize all APKs present.
cd /sdcard/vrtheme/flags
for f in /sdcard/vrtheme/flags/*.apk; do
	[ -e $f ] || break
	ui_print " - $f"
	clrdex $f
done

# Finally we remove the vrtheme folder, but retain the backups. I mean, why do
# a backup if we're just going to delete the backup afterwards?
$bb mv /sdcard/vrtheme/backup /sdcard/vrtheme_backup
$deldir /sdcard/vrtheme

exit 0
