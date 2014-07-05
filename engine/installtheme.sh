#!/sbin/sh

# Enhanced VRTheme engine v1.2
# Copyright Aurel Jared Dantis 2014.
#
# Original VRTheme engine is copyright
# VillainROM 2011. All rights reserved.
# Edify-like methods defined below are
# copyright Chainfire 2011.

# Declare busybox and output file descriptor
bb="/tmp/busybox"
OUTFD=$(ps | grep -v "grep" | grep -o -E "update_binary(.*)" | cut -d " " -f 3);

[ $OUTFD != "" ] || OUTFD=$(ps | grep -v "grep" | grep -o -E "updater(.*)" | cut -d " " -f 3);

# Define some methods
ui_print() {
  if [ $OUTFD != "" ]; then
    echo "ui_print ${1} " 1>&$OUTFD;
    echo "ui_print " 1>&$OUTFD;
  else
    echo "${1}";
  fi;
}

dir() {
	$bb mkdir -p $1
}

zpln() {
	/tmp/zipalign -f -v 4 $1 ./aligned/$1
}

zip() {
	/tmp/zip -r $1 $2
}

checkdex() {
	if [ -f ./classes.dex ]; then
		echo "# This is a flag for cleanup.sh" > /sdcard/vrtheme/flags/$1
		echo "# to delete this app's dex entry" >> /sdcard/vrtheme/flags/$1
	fi
}

# cleanup.sh will look here to see what apps
# need their dex entries refreshed.
dir /sdcard/vrtheme/flags

# Back up original APKs
ui_print ""
ui_print "Backing up system apps"
dir /sdcard/vrtheme/backup/system/app
dir /sdcard/vrtheme/apply/system/app
cd /sdcard/vrtheme/system/app/
for f in $(ls)
do
  ui_print "- $f"
  cp /system/app/$f /sdcard/vrtheme/apply/system/app/
  cp /system/app/$f /sdcard/vrtheme/backup/system/app/
done
ui_print "Backups done for system apps"

[ -d /sdcard/vrtheme/preload/symlink/system/app ] && preload=1 || preload=0
if [ "$preload" -eq "1" ]; then
	ui_print "Backing up preload apps"
	dir /sdcard/vrtheme-backup/preload/symlink/system/app
	dir /sdcard/vrtheme/apply/preload/symlink/system/app
	cd /sdcard/vrtheme/preload/symlink/system/app/
	for f in $(ls)
		do
		ui_print "- $f"
  	cp /preload/symlink/system/app/$f /sdcard/vrtheme/apply/preload/symlink/system/app/
  	cp /preload/symlink/system/app/$f /sdcard/vrtheme-backup/preload/symlink/system/app/
	done
	ui_print "Backups done for preload apps"
fi

[ -d /sdcard/vrtheme/system/framework ] && framework=1 || framework=0
if [ "$framework" -eq "1" ]; then
	ui_print "Backing up frameworks"
	dir /sdcard/vrtheme-backup/system/framework
	dir /sdcard/vrtheme/apply/system/framework
	cd /sdcard/vrtheme/system/framework
	for f in $(ls)
		do
  	ui_print "- $f"
 		cp /system/framework/$f /sdcard/vrtheme/apply/system/framework/
  	cp /system/framework/$f /sdcard/vrtheme-backup/system/framework/
	done
	ui_print "Backups done for frameworks"
fi

[ -d /sdcard/vrtheme/data/sec_data ] && datasecapps=1 || datasecapps=0
if [ "$datasecapps" -eq "1" ]; then
	ui_print "Backing up sec_data"
	dir /sdcard/vrtheme-backup/data/sec_data/
	dir /sdcard/vrtheme/apply/data/sec_data/
	cd /sdcard/vrtheme/data/sec_data/
	for f in $(ls)
		do
  	ui_print "- $f"
  	cp /data/sec_data/$f /sdcard/vrtheme/apply/data/sec_data/
  	cp /data/sec_data/$f /sdcard/vrtheme-backup/data/sec_data/
	done
	ui_print "Backups done for sec_data"
fi

[ -d /sdcard/vrtheme/data/app ] && dataapps=1 || dataapps=0
if [ "$dataapps" -eq "1" ]; then
	ui_print "Backing up user apps"
	dir /sdcard/vrtheme-backup/data/app/
	dir /sdcard/vrtheme/apply/data/app/
	cd /sdcard/vrtheme/data/app/
	for f in $(ls)
		do
  	ui_print "- $f"
  	cp /data/app/$f /sdcard/vrtheme/apply/data/app/
  	cp /data/app/$f /sdcard/vrtheme-backup/data/app/
	done
	ui_print "Backups done for user apps"
fi

# Theme the apps
ui_print ""
ui_print "-------THEMEING APPS NOW!-------"

cd /sdcard/vrtheme/apply/system/app/
for f in $(ls)
do
  ui_print "Working on $f"
  cd /sdcard/vrtheme/system/app/$f/
  mv /sdcard/vrtheme/apply/system/app/$f /sdcard/vrtheme/apply/system/app/$f.zip
  zip /sdcard/vrtheme/apply/system/app/$f.zip *
  mv /sdcard/vrtheme/apply/system/app/$f.zip /sdcard/vrtheme/apply/system/app/$f
  checkdex $f
done
ui_print "- Themed system apps"

if [ "$preload" -eq "1" ]; then
cd /sdcard/vrtheme/apply/preload/symlink/system/app/
for f in $(ls)
do
  ui_print "Working on $f"
  cd /sdcard/vrtheme/preload/symlinkl/system/app/$f/
  mv /sdcard/vrtheme/apply/preload/symlink/system/app/$f /sdcard/vrtheme/apply/preload/symlink/system/app/$f.zip
  zip /sdcard/vrtheme/apply/preload/symlink/system/app/$f.zip *
  mv /sdcard/vrtheme/apply/preload/symlink/system/app/$f.zip /sdcard/vrtheme/apply/preload/symlink/system/app/$f
  checkdex $f
done
ui_print "- Themed preload apps"
fi
if [ "$framework" -eq "1" ]; then
cd /sdcard/vrtheme/apply/system/framework/
for f in $(ls)
do
  ui_print "Working on $f"
  cd /sdcard/vrtheme/system/framework/$f/
  mv /sdcard/vrtheme/apply/system/framework/$f /sdcard/vrtheme/apply/system/framework/$f.zip
  zip /sdcard/vrtheme/apply/system/framework/$f.zip *
  mv /sdcard/vrtheme/apply/system/framework/$f.zip /sdcard/vrtheme/apply/system/framework/$f
  checkdex $f
done
ui_print "- Themed frameworks"
fi

if [ "$datasecapps" -eq "1" ]; then
cd /sdcard/vrtheme/apply/data/sec_data/
for f in $(ls)
do
  ui_print "Working on $f"
  cd /sdcard/vrtheme/data/sec_data/$f/
  mv /sdcard/vrtheme/apply/data/sec_data/$f /sdcard/vrtheme/apply/data/sec_data/$f.zip
  zip /sdcard/vrtheme/apply/data/sec_data/$f.zip *
  mv /sdcard/vrtheme/apply/data/sec_data/$f.zip /sdcard/vrtheme/apply/data/sec_data/$f
  checkdex $f
done
ui_print "- Themed sec_data files"
fi

if [ "$dataapps" -eq "1" ]; then
cd /sdcard/vrtheme/apply/data/app/
for f in $(ls)
do
  ui_print "Working on $f"
  cd /sdcard/vrtheme/data/app/$f/
  mv /sdcard/vrtheme/apply/data/app/$f /sdcard/vrtheme/apply/data/app/$f.zip
  zip /sdcard/vrtheme/apply/data/app/$f.zip *
  mv /sdcard/vrtheme/apply/data/app/$f.zip /sdcard/vrtheme/apply/data/app/$f
  checkdex $f
done
ui_print "- Themed user apps"
fi

# Zipalign all the APKs
ui_print ""
cd /sdcard/vrtheme/apply/system/app/
$bb mkdir aligned
for f in $(ls *.apk)
do
  ui_print "Zipaligning $f"
	zpln $f
done
if [ "$preload" -eq "1" ]; then
cd /sdcard/vrtheme/apply/preload/symlink/system/app/
$bb mkdir aligned
for f in $(ls *.apk)
do
  ui_print "Zipaligning $f"
  zpln $f
done
fi
if [ "$framework" -eq "1" ]; then
cd /sdcard/vrtheme/apply/system/framework/
$bb mkdir aligned
for f in $(ls *.apk)
do
  ui_print "Zipaligning $f"
  zpln $f
done
fi
if [ "$datasecapps" -eq "1" ]; then
cd /sdcard/vrtheme/apply/data/sec_data/
$bb mkdir aligned
for f in $(ls *.apk)
do
  ui_print "Zipaligning $f"
  zpln $f
done
fi
if [ "$dataapps" -eq "1" ]; then
cd /sdcard/vrtheme/apply/data/app/
$bb mkdir aligned
for f in $(ls *.apk)
do
  ui_print "Zipaligning $f"
  zpln $f
done
fi

# Move each new app back to its original location
cd /sdcard/vrtheme/apply/system/app/aligned/
cp * /system/app/
chmod 644 /system/app/*
if [ "$preload" -eq "1" ]; then
cd /sdcard/vrtheme/apply/preload/symlink/system/app/aligned/
cp * /preload/symlink/system/app/
chmod 644 /preload/symlink/system/app/*
fi
if [ "$framework" -eq "1" ]; then
cd /sdcard/vrtheme/apply/system/framework/aligned/
cp * /system/framework
chmod 644 /system/framework/*
fi
if [ "$datasecapps" -eq "1" ]; then
cd /sdcard/vrtheme/apply/data/sec_data/aligned/
cp * /data/sec_data/
chmod 644 /data/sec_data/*
fi
if [ "$dataapps" -eq "1" ]; then
cd /sdcard/vrtheme/apply/data/app/aligned/
cp * /data/app/
chmod 644 /data/app/*
fi

ui_print ""
ui_print "**Themeing process complete**"
exit 0