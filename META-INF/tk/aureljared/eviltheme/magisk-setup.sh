#!/sbin/sh
# Eviltheme by Jared Dantis (@aureljared)
# Licensed under GPL v3
# https://github.com/aureljared/eviltheme
. "$1"
MODDIR="$2"

# Create module.prop
cat << EOF > "$MODDIR/module.prop"
id=$themeId
name=$themeName
version=$themeVersion
versionCode=$themeVersionCode
author=$themeAuthor
description=$themeDescription
donate=$themeDonate
support=$themeSupport
template=1400
EOF
touch "$MODDIR/auto_mount"
exit 0
