# gPodder 4 for Sailfish OS

This repository contains the platform-specific customizations and packaging for
running gPodder 4 on Sailfish OS. Python 3.3.3 and PyOtherSide is already included
in the device repositories starting with Sailfish OS 1.0.3.8.

## Getting Started with Development

As of July 2019 an effort was made to make the product play nice in the SDK.
You can now open the project in the SailfishOS SDK and build/deploy directly from there.
The method listed below for developing probably still work too.
To use the build method listed below you will need to revert to the old RPM spec file.

### Development on Device/ in Emulator

There is the possibility to directly clone the repository to the device/ emulator and work there:

1. Connect via SSH to your SailfishOS device
    e.g. connect to emulator: `ssh -p 2223 -i ~/SailfishOS/vmshare/ssh/private_keys/SailfishOS_Emulator/nemo nemo@localhost`
1. Install the needed packages: `pkcon install git pyotherside-qml-plugin-python3-qt5`
1. Clone this repo: `git clone --recursive https://github.com/gpodder/gpodder-sailfish.git`
1. Set up development symlinks:
    ```
    cd gpodder-sailfish
    bash dev_symlinks.sh
    ```
1. Launch main qml file: `/usr/lib/qt5/bin/qmlscene qml/harbour-org.gpodder.sailfish.qml`

### Building RPM Package

The RPM package can be build in the *SailfishOS Build Engine* VM

1. Start the *Sailfish OS Build Engine* VM
1. Connect to it via SSH: `ssh -p 2222 -i ~/SailfishOS/vmshare/ssh/private_keys/engine/mersdk mersdk@localhost`
1. Move to your source code directory. You can usually access your home directory via the `~/share/` directory from inside the build engine
1. In case you created development symlinks (see above): remove them using `bash dev_symlinks --unlink`
1. Build the package using `mb2 -t SailfishOS-armv7hl build` (change target architecture to your needs)
1. The built package can be found in the `RPMS` directory.
