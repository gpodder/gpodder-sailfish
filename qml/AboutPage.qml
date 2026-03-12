
/**
 *
 * gPodder QML UI Reference Implementation
 * Copyright (c) 2014, Thomas Perl <m@thp.io>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
 * REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
 * LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
 * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: aboutPage
    allowedOrientations: Orientation.All

    onStatusChanged: pgst.handlePageStatusChange(status)

    SilicaFlickable {
        id: flickable
        anchors.fill: parent

        VerticalScrollDecorator { flickable: flickable }

        contentWidth: aboutColumn.width
        contentHeight: aboutColumn.height + aboutColumn.spacing

        Column {
            id: aboutColumn

            width: aboutPage.width
            spacing: Theme.paddingMedium


            PageHeader {
                title: qsTr("About gPodder")
            }

            Column {
                spacing: Theme.paddingLarge

                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }

                Column {
                    Label {
                        text: 'gPodder ' + py.uiversion
                        color: Theme.highlightColor
                    }

                    Label {
                        text: 'http://gpodder.org/'
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.secondaryColor
                    }
                }

                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    text: [
                        '© 2005-2025 '+ qsTr("Thomas Perl and the gPodder Team"),
                        qsTr("License: ISC / GPLv3 or later"),
                        qsTr("Website: ") + 'http://gpodder.org/',
                        '',
                        qsTr("Sailfish OS artwork by Stephan Beyerle"),
                        '',
                        'gPodder Core ' + py.coreversion,
                        'gPodder Sailfish ' + py.uiversion,
                        'Podcastparser ' + py.parserversion,
                        'PyOtherSide ' + py.pluginVersion(),
                        'Python ' + py.pythonVersion()
                    ].join('\n')
                }
            }
        }
    }
}
