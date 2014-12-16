#!/sbin/sh

# Enhanced VRTheme engine v1.5
# Copyright Aurel Jared Dantis, 2014.
#
# Original VRTheme engine is copyright
# VillainROM 2011. All rights reserved.
# Edify-like methods defined below are
# copyright Chainfire 2011.

# Declare busybox and output file descriptor
bb="/tmp/busybox"
OUTFD=$(ps | grep -v "grep" | grep -o -E "update_binary(.*)" | cut -d " " -f 3);

[ $OUTFD != "" ] || OUTFD=$(ps | grep -v "grep" | grep -o -E "updater(.*)" | cut -d " " -f 3);

# Check if ROM is Lollipop+ or not
apiLevel=$(getprop ro.build.version.sdk)
if [[ $apiLevel >= "21" ]]; then
	lollipop=1
	ui_print "- Adjusting engine for Lollipop ROM"
	appName() {
		echo "$(echo $1 | $bb sed -e 's/\.apk//g')/$1"
	}
	appFolder() {
		echo "$(echo $1 | $bb sed -e 's/\.apk//g')"
	}
else
	appName() {
		echo "$1"
	}
fi

# Declare location shortcuts
vrroot=/sdcard/vrtheme
f1=$vrroot/system/app
f1_1=$vrroot/system/priv-app
f2=$vrroot/preload/system/app
f3=$vrroot/system/framework
f4=$vrroot/data/sec_app
f5=$vrroot/apply/system/app
f5priv=$vrroot/apply/system/priv-app
f6=$vrroot/apply/preload/system/app
f7=$vrroot/apply/system/framework
f8=$vrroot/apply/data/sec_app

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

theme() {
	/tmp/zip -r -q $1 $2
}

checkdex() {
	if [ -f ./classes.dex ]; then
		echo "# This is a flag for cleanup.sh" > $vrroot/flags/$1
		echo "# to delete this app's dex entry" >> $vrroot/flags/$1
	fi
}

# cleanup.sh will look here to see what apps need their dex entries refreshed.
dir $vrroot/flags

# Remove placeholder files that will otherwise inhibit proper themeing.
locations=(data/sec_data system/app system/priv-app system/framework preload/symlink/system/app data/app)
for folder in $locations; do
	cd /$folder
	for dummyFile in $($bb find . | grep 'placeholder'); do
		rm $dummyFile
	done
	cd $vrroot/$folder
	for dummyFile in $($bb find . | grep 'placeholder'); do
		rm $dummyFile
	done
done

# Back up original APKs
ui_print "- Backing up apps"
[ -f $vrroot/system/app/* ] && sysapps=1 || sysapps=0
if [ $sysapps == "1" ]; then
	dir $vrroot/backup/system/app
	dir $vrroot/apply/system/app
	for f in $(ls $f1); do
	  ui_print " - $f"
	  cp /system/app/$(appName $f) $vrroot/apply/system/app/
	  cp /system/app/$(appName $f) $vrroot/backup/system/app/
	done
	ui_print ""
fi

[ -f $vrroot/system/priv-app/* ] && privapps=1 || privapps=0
if [ $privapps == "1" ]; then
	dir $vrroot/backup/system/priv-app
	dir $vrroot/apply/system/priv-app
	for f in $(ls $f1_1); do
	  ui_print " - $f"
	  cp /system/priv-app/$(appName $f) $vrroot/apply/system/priv-app/
	  cp /system/priv-app/$(appName $f) $vrroot/backup/system/priv-app/
	done
	ui_print ""
fi

[ -f $vrroot/preload/symlink/system/app/* ] && preload=1 || preload=0
if [ $preload == "1" ]; then
	ui_print "- Backing up preload apps"
	dir $vrroot/backup/preload/symlink/system/app
	dir $vrroot/apply/preload/symlink/system/app
	for f in $(ls $f2); do
		ui_print " - $f"
		cp /preload/symlink/system/app/$(appName $f) $vrroot/apply/preload/symlink/system/app/
		cp /preload/symlink/system/app/$(appName $f) $vrroot/backup/preload/symlink/system/app/
	done
	ui_print "Backups done for preload apps"
	ui_print ""
fi

[ -f $vrroot/system/framework/* ] && framework=1 || framework=0
if [ $framework == "1" ]; then
	dir $vrroot/backup/system/framework
	dir $vrroot/apply/system/framework
	for f in $(ls $f3); do
		ui_print " - $f"
		cp /system/framework/$f $vrroot/apply/system/framework/
		cp /system/framework/$f $vrroot/backup/system/framework/
	done
fi

[ -f $vrroot/data/sec_data/* ] && datasecapps=1 || datasecapps=0
if [ $datasecapps == "1" ]; then
	dir $vrroot/backup/data/sec_data/
	dir $vrroot/apply/data/sec_data/
	for f in $(ls $f4); do
		ui_print " - $f"
		cp /data/sec_data/$f $vrroot/apply/data/sec_data/
		cp /data/sec_data/$f $vrroot/backup/data/sec_data/
	done
fi

# Theme the apps
ui_print "- Themeing apps"

if [ $sysapps == "1" ]; then
	cd $vrroot/system/app/
	for f in $(ls $f5)
	do
	  ui_print "* $f"
	  mv $vrroot/apply/system/app/$f $vrroot/apply/system/app/$f.zip
	  theme $vrroot/apply/system/app/$f.zip *
	  mv $vrroot/apply/system/app/$f.zip $vrroot/apply/system/app/$f
	  checkdex $f
	done
fi

if [ $privapps == "1" ]; then
	cd $vrroot/system/priv-app/
	for f in $(ls $f5priv); do
	  ui_print "* $f"
	  mv $vrroot/apply/system/priv-app/$f $vrroot/apply/system/priv-app/$f.zip
	  theme $vrroot/apply/system/priv-app/$f.zip *
	  mv $vrroot/apply/system/priv-app/$f.zip $vrroot/apply/system/priv-app/$f
	  checkdex $f
	done
fi

if [ $preload == "1" ]; then
	cd $vrroot/preload/symlink/system/app/
	for f in $(ls $f6); do
	  ui_print " - $f"
	  mv $vrroot/apply/preload/symlink/system/app/$f $vrroot/apply/preload/symlink/system/app/$f.zip
	  theme $vrroot/apply/preload/symlink/system/app/$f.zip *
	  mv $vrroot/apply/preload/symlink/system/app/$f.zip $vrroot/apply/preload/symlink/system/app/$f
	  checkdex $f
	done
fi

if [ $framework == "1" ]; then
	cd $vrroot/system/framework/
	for f in $(ls $f7); do
	  ui_print " - $f"
	  mv $vrroot/apply/system/framework/$f $vrroot/apply/system/framework/$f.zip
	  theme $vrroot/apply/system/framework/$f.zip *
	  mv $vrroot/apply/system/framework/$f.zip $vrroot/apply/system/framework/$f
	  checkdex $f
	done
fi

if [ $datasecapps == "1" ]; then
	cd $vrroot/data/sec_data/
	for f in $(ls $f8); do
	  ui_print " - $f"
	  mv $vrroot/apply/data/sec_data/$f $vrroot/apply/data/sec_data/$f.zip
	  theme $vrroot/apply/data/sec_data/$f.zip *
	  mv $vrroot/apply/data/sec_data/$f.zip $vrroot/apply/data/sec_data/$f
	  checkdex $f
	done
fi

# Zipalign all the APKs
ui_print "- Zipaligning themed apps"
if [ $sysapps == "1" ]; then
	cd $vrroot/apply/system/app/
	$bb mkdir aligned
	for f in $(ls $f5/*.apk); do
	  zpln $f
	done
fi

if [ $privapps == "1" ]; then
	cd $vrroot/apply/system/priv-app/
	$bb mkdir aligned
	for f in $(ls $f5priv/*.apk); do
	  zpln $f
	done
fi

if [ $preload == "1" ]; then
	cd $vrroot/apply/preload/symlink/system/app/
	$bb mkdir aligned
	for f in $(ls $f6/*.apk); do
	  zpln $f
	done
fi

if [ $framework == "1" ]; then
	cd $vrroot/apply/system/framework/
	$bb mkdir aligned
	for f in $(ls $f7/*.apk); do
	  zpln $f
	done
fi

if [ $datasecapps == "1" ]; then
	cd $vrroot/apply/data/sec_data/
	$bb mkdir aligned
	for f in $(ls $f8/*.apk); do
	  zpln $f
	done
fi

# Move each new app back to its original location
if [ $sysapps == "1" ]; then
	cd $vrroot/apply/system/app/aligned/
	if [[ $lollipop == "1" ]]; then
		for f in $(ls $f5/aligned/*.apk); do
			cp $f /system/app/$(appFolder $f)/
		done
	else
		cp * /system/app/
	fi
	chmod -R 644 /system/app/*
fi

if [ $privapps == "1" ]; then
	cd $vrroot/apply/system/priv-app/aligned/
	if [[ $lollipop == "1" ]]; then
		for f in $(ls $f5-priv/aligned/*.apk); do
			cp $f /system/priv-app/$(appFolder $f)/
		done
	else
		cp * /system/priv-app/
	fi
	chmod -R 644 /system/priv-app/*
fi

if [ $preload == "1" ]; then
	cd $vrroot/apply/preload/symlink/system/app/aligned/
	if [[ $lollipop == "1" ]]; then
		for f in $(ls $f6/aligned/*.apk); do
			cp $f /preload/symlink/system/app/$(appFolder $f)/
		done
	else
		cp * /preload/symlink/system/app/
	fi
	chmod -R 644 /preload/symlink/system/app/*
fi

if [ $framework == "1" ]; then
	cd $vrroot/apply/system/framework/aligned/
	cp * /system/framework
	chmod -R 644 /system/framework/*
fi

if [ $datasecapps == "1" ]; then
	cd $vrroot/apply/data/sec_data/aligned/
	cp * /data/sec_data/
	chmod -R 644 /data/sec_data/*
fi

exit 0
