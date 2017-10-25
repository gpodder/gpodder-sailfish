# gPodder 4 for Sailfish OS

This repository contains the platform-specific customizations and packaging for
running gPodder 4 on Sailfish OS. Python 3.3.3 and PyOtherSide is already included
in the device repositories starting with Sailfish OS 1.0.3.8.

## getting started with development

### development on device/ in emulator

There is the possibility to directly clone the repository to the device/ emulator and work there:

1. connect via SSH to your SailfishOS device
    e.g. connect to emulator: `ssh -p 2223 -i ~/SailfishOS/vmshare/ssh/private_keys/SailfishOS_Emulator/nemo nemo@localhost`
1. install the needed packages: `pkcon install git pyotherside-qml-plugin-python3-qt5`
1. clone this repo: `git clone --recursive https://github.com/gpodder/gpodder-sailfish.git`
1. set up development symlinks:
    ```
    cd gpodder-sailfish
    sh dev_symlinks.sh
    ```
1. launch main qml file: `/usr/lib/qt5/bin/qmlscene qml/harbour-org.gpodder.sailfish.qml`
