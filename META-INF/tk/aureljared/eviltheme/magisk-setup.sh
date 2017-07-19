#!/sbin/sh
# Eviltheme by Jared Dantis (@aureljared)
# Licensed under GPL v3
# https://github.com/aureljared/eviltheme
. "$1"
target="$2"
templateVersion="$3"

# Create module.prop
cat << EOF > "$target/module.prop"
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
touch "$target/auto_mount"
exit 0
