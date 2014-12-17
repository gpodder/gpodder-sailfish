#!/bin/sh
# Create symlinks into Git submodules, so the project can
# be started with qmlscene directly from a source checkout

ln -sf gpodder-core/src/gpodder .
ln -sf podcastparser/podcastparser.py .
ln -sf gpodder-ui-qml/main.py .
ln -sf ../gpodder-ui-qml/common qml
