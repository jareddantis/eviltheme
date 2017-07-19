#!/sbin/sh
# Eviltheme by Jared Dantis (@aureljared)
# Licensed under GPL v3
# https://github.com/aureljared/eviltheme
. "$1"
MODDIR="$2"
templateVersion="$3"

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
template=$templateVersion
EOF
touch "$MODDIR/auto_mount"
exit 0
