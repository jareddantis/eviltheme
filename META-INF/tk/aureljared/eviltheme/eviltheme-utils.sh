# Eviltheme by Jared Dantis (@aureljared)
# Licensed under GPL v3
# https://github.com/aureljared/eviltheme

cleanup() {
    ui_print "Cleaning up and unmounting filesystems"
    rm -rf $vrroot $vrbackupstaging
    [ "$SYSTEMLESS" -eq "1" ] && umount $sumnt
    [ "$art" -eq "0" ] && umount /cache
    umount /system
    umount /data
    umount /preload
}

list_new_sysfiles() {
    echo "$(unzip -l $1 'system/*' | tr -s ' ' ' ' | sed 1,3d | head -n -2 | grep -v "^ 0" | cut -f5 -d' ')"
}
list_new_datafiles() {
    echo "$(unzip -l $1 'data/*' | tr -s ' ' ' ' | sed 1,3d | head -n -2 | grep -v "^ 0" | cut -f5 -d' ')"
}

friendlyname() {
    # Example: Return "Settings" for "Settings.apk"
    tempvar="$(echo $1 | sed 's/.apk//g')"
    echo "$tempvar"
}

theme_app(){
    path="$1/$2" # system/app

    # Do not put preload files in Magisk image
    foldername="$(echo $1 | cut -f1 -d/)"
    [ "$foldername" == "preload" ] && vrout="/$path" || vrout="$target/$2"
    mkdir -p "$vrout"

    cd "$vrroot/$path/"
    mkdir -p "$vrbackupstaging/$path"
    mkdir -p "$vrroot/apply/$path"

    for f in *.apk; do
        cd "$f"
        ui_print " => /$path/$f"

        # Backup APK
        if [ "$art" -eq "1" ]; then
            appPath="$(friendlyname $f)/$f"
            mkdir -p "$vrroot/apply/$path/$(friendlyname $f)"
            cp "/$path/$appPath" "$vrroot/apply/$path/$(friendlyname $f)/"
            if [ "$SYSTEMLESS" -eq "0" ]; then
                mkdir -p "$vrbackupstaging/$path/$(friendlyname $f)"
                cp "/$path/$appPath" "$vrbackupstaging/$path/$(friendlyname $f)/"
            fi
        else
            [ "$SYSTEMLESS" -eq "0" ] && cp "/$path/$f" "$vrbackupstaging/$path/"
            cp "/$path/$f" "$vrroot/apply/$path/"
            appPath="$f"
        fi

        # Delete files in APK, if any
        mv "$vrroot/apply/$path/$appPath" "$vrroot/apply/$path/$appPath.zip"
        if [ -e "./delete.list" ]; then
            while IFS='' read item; do
                $vrengine/zip -d "$vrroot/apply/$path/$appPath.zip" "$item"
            done < ./delete.list
            rm -f ./delete.list
        fi

        # Theme APK
        $vrengine/zip -r "$vrroot/apply/$path/$appPath.zip" ./*
        mv "$vrroot/apply/$path/$appPath.zip" "$vrroot/apply/$path/$appPath"

        # Refresh bytecode if necessary
        checkdex "$2" "$f"

        # Finish up
        [ "$SYSTEMLESS" -eq "1" ] && mkdir -p "$vrout/$(friendlyname $f)"
        cp -f "$vrroot/apply/$path/$appPath" "$vrout/$appPath"
        chown 0:0 "$vrout/$appPath"
        chmod 644 "$vrout/$appPath"
        cd "$vrroot/$path/"
    done
}

theme_framework(){
    path="$1/$2" # system/framework
    vrout="$target/$2"
    mkdir -p "$vrout"

    cd "$vrroot/$path/"
    mkdir -p "$vrbackupstaging/$path"
    mkdir -p "$vrroot/apply/$path"

    for f in *.apk; do
        cd "$f"
        ui_print " => /$path/$f"

        # Backup APK
        [ "$SYSTEMLESS" -eq "0" ] && cp "/$path/$f" "$vrbackupstaging/$path/"
        cp "/$path/$f" "$vrroot/apply/$path/"
        appPath="$f"

        # Delete files in APK, if any
        mv "$vrroot/apply/$path/$appPath" "$vrroot/apply/$path/$appPath.zip"
        if [ -e "./delete.list" ]; then
            while IFS='' read item; do
                $vrengine/zip -d "$vrroot/apply/$path/$appPath.zip" "$item"
            done < ./delete.list
            rm -f ./delete.list
        fi

        # Theme APK
        $vrengine/zip -r "$vrroot/apply/$path/$appPath.zip" ./*
        mv "$vrroot/apply/$path/$appPath.zip" "$vrroot/apply/$path/$appPath"

        # Refresh bytecode if necessary
        [ "$2" == "samsung-framework-res" ] && checkdex "framework@$2" "$f" || checkdex "$2" "$f"

        # Finish up
        [ "$SYSTEMLESS" -eq "1" ] && mkdir -p "$vrout/$(friendlyname $f)"
        cp -f "$vrroot/apply/$path/$appPath" "$vrout/$appPath"
        chown 0:0 "$vrout/$appPath"
        chmod 644 "$vrout/$appPath"
        cd "$vrroot/$path/"
    done
}
