# eviltheme

Eviltheme (**E**nhanced **Vil**lainROM **Theme** Engine) is an Android system modification platform meant for use with custom Android recoveries.
It allows modification of application resources without the need to replace the whole app or install a new operating system.

Eviltheme is based on the VRTheme Engine from 2011, though versions 3.x.x and up heavily differ from the original VillainROM code.

## Features

- Automatic systemless mode (Magisk v13.1+, Android 6+ required)
- System mode fallback in case Magisk is not present
- Supports both Dalvik and ART platforms
- Smart bytecode refresh (delete classes.dex/classes.art only if it is replaced by the theme)
- Easy uninstallation via automatically generated flashable ZIP
- Delete files (even inside APKs)

## Scripts

- `META-INF/com/google/android/update-binary` - main script
- `META-INF/tk/aureljared/eviltheme/recovery-utils.sh` - functions for recovery, like `ui_print` and `set_perm_recursive`
- `META-INF/tk/aureljared/eviltheme/eviltheme-utils.sh` - EVilTheme functions. This is where the theming logic is defined
- `META-INF/tk/aureljared/eviltheme/permissions.sh-example` - example script for setting custom theme permissions
- `META-INF/tk/aureljared/eviltheme/custom.sh-example` - example script for custom theme post-installation script
- `META-INF/tk/aureljared/eviltheme/magisk-setup.sh` - script that handles Magisk Module Template compatibility (module.prop creation)

## Usage

[XDA-Developers](https://forum.xda-developers.com/showthread.php?t=2774436)

## Credits

- @djb77
- @Spannaa
- @topjohnwu
- The VillainROM team
