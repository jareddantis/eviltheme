#!/sbin/sh

# Enhanced VRTheme engine v2.0.4
# Copyright aureljared@XDA, 2014-2015.
#
# Original VRTheme engine is copyright
# VillainROM 2011. All rights reserved.
# Edify-like methods defined below are
# copyright Chainfire 2011.
#
# Portions are copyright Spannaa@XDA 2015.

# Declare busybox and output file descriptor
bb="/tmp/busybox"
datetime=$($bb date +"%m%d%y-%H%M%S")
OUTFD=$(ps | grep -v "grep" | grep -o -E "update_binary(.*)" | cut -d " " -f 3);
[ $OUTFD != "" ] || OUTFD=$(ps | grep -v "grep" | grep -o -E "updater(.*)" | cut -d " " -f 3);

# Check if ROM is Lollipop+ or not
getpropval() {
	acquiredValue=`cat $1 | grep "^$2=" | cut -d"=" -f2 | tr -d '\r '`
	echo "$acquiredValue"
}
platformString=`getpropval /system/build.prop "ro.build.version.release"`
platform=`echo "$platformString" | cut -d. -f1`
if [ "$platform" -ge "5" ]; then
	lollipop="1"
	ui_print "- Adjusting engine for new app hierarchy"
	friendlyname() {
		# Example: Return "Settings" for "Settings.apk"
		tempvar="$(echo $1 | $bb sed 's/.apk//g')"
		echo "$tempvar"
	}
	checkdex() {
		tmpvar=$(friendlyname "$2")
		if [ -e ./classes.dex ]; then
			rm -f "/data/dalvik-cache/arm/system@$1@$tmpvar@$2.apk@classes.dex"
		fi
	}
else
	checkdex() {
		if [ -e ./classes.dex ]; then
			if [ -e "/data/dalvik-cache/system@$1@$2@classes.dex" ]; then
				rm -f "/data/dalvik-cache/system@$1@$2@classes.dex"
			else
				rm -f "/cache/dalvik-cache/system@$1@$2@classes.dex"
			fi
		fi
	}
fi

# Define some methods
ui_print() {
	# Print to recovery screen
	if [ $OUTFD != "" ]; then
		echo "ui_print ${1} " 1>&$OUTFD;
		echo "ui_print " 1>&$OUTFD;
	else
		echo "${1}";
	fi;
}
dir() {
	# Make folder $1 if it doesn't exist yet
	if [ ! -d "$1" ]; then
		$bb mkdir -p "$1"
	fi
}
zpln() {
	# Zipalign $1 into aligned/$1
	if [ "$lollipop" -eq "1" ]; then
		appDir=$(echo $1 | sed "s/\/$1\.apk")
		$bb mkdir -p ./aligned/$appDir
	fi
	/tmp/zipalign -f 4 "$1" ./aligned/$1
}

# I don't think functions work well for this purpose
theme="/tmp/zip -r"

# Work directories
vrroot="/data/tmp/eviltheme"
vrbackup="/data/tmp/evt-backup"
dir "$vrbackup"
dir "$vrroot/apply"

# Start theming
ui_print "- Theming apps"
[ -d "$vrroot/system/app" ] && sysapps=1 || sysapps=0
[ -d "$vrroot/system/priv-app" ] && privapps=1 || privapps=0
[ -d "$vrroot/system/framework" ] && framework=1 || framework=0
[ -d "$vrroot/preload/symlink/system/app" ] && preload=1 || preload=0

# /system/app
if [ "$sysapps" -eq "1" ]; then
	cd "$vrroot/system/app/"
	dir "$vrbackup/system/app"
	dir "$vrroot/apply/system/app"
	dir "$vrroot/apply/system/app/aligned"

	for f in *.apk; do
		cd "$f"
		ui_print "  sa: $f"

		# Backup APK
		if [ "$lollipop" -eq "1" ]; then
			appPath="$(friendlyname $f)/$f"
			dir "$vrbackup/system/app/$(friendlyname $f)"
			dir "$vrroot/apply/system/app/$(friendlyname $f)"
			cp "/system/app/$appPath" "$vrbackup/system/app/$(friendlyname $f)/"
			cp "/system/app/$appPath" "$vrroot/apply/system/app/$(friendlyname $f)/"
		else
			cp "/system/app/$f" "$vrbackup/system/app/"
			cp "/system/app/$f" "$vrroot/apply/system/app/"
			appPath="$f"
		fi

		# Theme APK
		mv "$vrroot/apply/system/app/$appPath" "$vrroot/apply/system/app/$appPath.zip"
		$theme "$vrroot/apply/system/app/$appPath.zip" ./*
		mv "$vrroot/apply/system/app/$appPath.zip" "$vrroot/apply/system/app/$appPath"

		# Refresh bytecode if necessary
		checkdex "app" "$f"

		# Zipalign APK
		cd "$vrroot/apply/system/app"
		zpln "$appPath"

		# Finish up
		$bb cp -f "aligned/$appPath" "/system/app/$appPath"
		chmod 644 "/system/app/$appPath"
		cd "$vrroot/system/app/"
	done
fi

# /preload/symlink/system/app
if [ "$preload" -eq "1" ]; then
	cd "$vrroot/preload/symlink/system/app/"
	dir "$vrbackup/preload/symlink/system/app/"
	dir "$vrroot/apply/preload/symlink/system/app"
	dir "$vrroot/apply/preload/symlink/system/app/aligned"

	for f in *.apk; do
		cd "$f"
		ui_print "  pr: $f"

		# Backup APK
		cp "/preload/symlink/system/app/$f" "$vrbackup/preload/symlink/system/app/"
		cp "/preload/symlink/system/app/$f" "$vrroot/apply/preload/symlink/system/app/"

		# Theme APK
		mv "$vrroot/apply/preload/symlink/system/app/$f" "$vrroot/apply/preload/symlink/system/app/$f.zip"
		$theme "$vrroot/apply/preload/symlink/system/app/$f.zip" ./*
		mv "$vrroot/apply/preload/symlink/system/app/$f.zip" "$vrroot/apply/preload/symlink/system/app/$f"

		# Refresh bytecode if necessary
		checkdex "app" "$f"
		cd ../

		# Zipalign APK
		cd "$vrroot/apply/preload/symlink/system/app"
		zpln "$f"

		# Finish up
		$bb cp -f "aligned/$f" "/preload/symlink/system/app/"
		chmod 644 "/preload/symlink/system/app/$f"
		ln -s "/preload/symlink/system/app/$f" "/system/app/$f"
		cd "$vrroot/preload/symlink/system/app/"
	done
fi

# /system/priv-app
if [ "$privapps" -eq "1" ]; then
	cd "$vrroot/system/priv-app/"
	dir "$vrbackup/system/priv-app"
	dir "$vrroot/apply/system/priv-app"
	dir "$vrroot/apply/system/priv-app/aligned"

	for f in *.apk; do
		cd "$f"
		ui_print "  sp: $f"

		# Backup APK
		if [ "$lollipop" -eq "1" ]; then
			appPath="$(friendlyname $f)/$f"
			dir "$vrbackup/system/priv-app/$(friendlyname $f)"
			dir "$vrroot/apply/system/priv-app/$(friendlyname $f)"
			cp "/system/priv-app/$appPath" "$vrbackup/system/priv-app/$(friendlyname $f)/"
			cp "/system/priv-app/$appPath" "$vrroot/apply/system/priv-app/$(friendlyname $f)/"
		else
			cp "/system/priv-app/$f" "$vrbackup/system/priv-app/"
			cp "/system/priv-app/$f" "$vrroot/apply/system/priv-app/"
			appPath="$f"
		fi

		# Theme APK
		mv "$vrroot/apply/system/priv-app/$appPath" "$vrroot/apply/system/priv-app/$appPath.zip"
		$theme "$vrroot/apply/system/priv-app/$appPath.zip" ./*
		mv "$vrroot/apply/system/priv-app/$appPath.zip" "$vrroot/apply/system/priv-app/$appPath"

		# Refresh bytecode if necessary
		checkdex "priv-app" "$f"
		cd ../

		# Zipalign APK
		cd "$vrroot/apply/system/priv-app"
		zpln "$appPath"

		# Finish up
		$bb cp -f "aligned/$appPath" "/system/priv-app/$appPath"
		chmod 644 "/system/priv-app/$appPath"
		cd "$vrroot/system/priv-app/"
	done
fi

# /system/framework
if [ "$framework" -eq "1" ]; then
	cd "$vrroot/system/framework/"
	dir "$vrbackup/system/framework"
	dir "$vrroot/apply/system/framework"
	dir "$vrroot/apply/system/framework/aligned"

	for f in *.apk; do
		cd "$f"
		ui_print "  fw: $f"

		# Backup APK
		cp "/system/framework/$f" "$vrbackup/system/framework/"
		cp "/system/framework/$f" "$vrroot/apply/system/framework/"

		# Theme APK
		mv "$vrroot/apply/system/framework/$f" "$vrroot/apply/system/framework/$f.zip"
		$theme "$vrroot/apply/system/framework/$f.zip" ./*
		mv "$vrroot/apply/system/framework/$f.zip" "$vrroot/apply/system/framework/$f"

		# Refresh bytecode if necessary
		checkdex "framework" "$f"
		cd ../

		# Zipalign APK
		cd "$vrroot/apply/system/framework"
		zpln "$f"

		# Finish up
		$bb cp -f "aligned/$f" "/system/framework/"
		chmod 644 "/system/framework/$f"
		cd "$vrroot/system/framework/"
	done
fi

# Create flashable restore zip
ui_print "- Creating restore zip in /data/eviltheme-backup"
cd "$vrbackup"
dir "/data/eviltheme-backup"
mv /data/tmp/eviltheme/vrtheme_restore.zip "/data/eviltheme-backup/restore-$datetime.zip"
$theme "/data/eviltheme-backup/restore-$datetime.zip" ./*

# Cleanup
ui_print "- Cleaning up"
$bb rm -fR /data/tmp/eviltheme
$bb rm -fR /data/tmp/evt-backup
ui_print "Done. If your device does not perform properly after this,"
ui_print "just flash /data/eviltheme-backup/restore-$datetime.zip."

exit 0
