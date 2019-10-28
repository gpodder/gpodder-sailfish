# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-org.gpodder.sailfish

CONFIG += sailfishapp_qml sailfishapp_i18n

SOURCES +=

DEPLOY_PATH = /usr/share/$${TARGET}

common.files = gpodder-ui-qml/common/
common.path = $${DEPLOY_PATH}/qml/
gpodder.files = gpodder-core/src/*
gpodder.path = $${DEPLOY_PATH}/
minidb.files = minidb/minidb.py
minidb.path = $${DEPLOY_PATH}/
mainpy.files = gpodder-ui-qml/main.py
mainpy.path = $${DEPLOY_PATH}/
podcastparser.files = podcastparser/podcastparser.py
podcastparser.path = $${DEPLOY_PATH}/
myicons.files = icons/*
myicons.path = /usr/share/icons/hicolor/

OTHER_FILES += \
    rpm/harbour-org.gpodder.sailfish.spec \
    rpm/harbour-org.gpodder.sailfish.yaml \

INSTALLS += \
    common \
    gpodder \
    minidb \
    mainpy \
    podcastparser \
    myicons

TRANSLATIONS += \
    translations/harbour-org.gpodder.sailfish-es.ts \
    translations/harbour-org.gpodder.sailfish-de.ts \
    translations/harbour-org.gpodder.sailfish-bg.ts \
    translations/harbour-org.gpodder.sailfish-it.ts \
    translations/harbour-org.gpodder.sailfish-zh_CN.ts \
    translations/harbour-org.gpodder.sailfish.ts

TRANSLATION_SOURCES += /$$_PRO_FILE_PWD_/gpodder-ui-qml/common/

DISTFILES += \
    translations/*.ts
