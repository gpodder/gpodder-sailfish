
/**
 *
 * gPodder for Sailfish OS
 * Copyright (c) 2013-19, Thomas Perl <m@thp.io> and gPodder team
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

import 'common/util.js' as Util

Column {
    id: coverArt
    anchors {
        left: parent.left
        right: parent.right
    }

    Rectangle{
        id:emptySquare
        anchors.top: parent.top
        width: parent.width
        height: parent.width
        visible: false
    }

    Image {
        id: coverArtImage
        visible: source != ""
        source: player.podcast_coverart
        sourceSize.width: parent.width
        fillMode: Image.Pad
    }

    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: column.y + column.height + 2*Theme.paddingLarge
        visible: coverArtImage.visible
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.5) }
            GradientStop { position: 0.6; color: Qt.rgba(0, 0, 0, 0.5) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }



    Column {
        id: column

        x: Theme.paddingMedium
        y: Theme.paddingMedium
        spacing: Theme.paddingSmall
        width: parent.width - 2*Theme.paddingMedium


        Item {
            width: parent.width
            height: episodeTitle.height

            Label {
                id: episodeTitle
                text: player.episode_title
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(implicitWidth, parent.width)
                maximumLineCount: 4
                color: (coverArtImage.visible && Theme.colorScheme == Theme.DarkOnLight)
                       ? Theme.lightPrimaryColor : Theme.primaryColor
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeLarge
                lineHeightMode: Text.FixedHeight
                lineHeight: Theme.itemSizeMedium/2 // to align with clock cover text
                onLineLaidOut: {
                    // last line can show text as much as there fits
                    if (line.number == maximumLineCount - 1) {
                        line.width = parent.width + 1000
                    }
                }
            }

            OpacityRampEffect {
                offset: 0.66
                sourceItem: episodeTitle
                enabled: episodeTitle.implicitWidth > Math.ceil(episodeTitle.width)
            }
        }

    }

    Label {
        id: durationLabel
        width: parent.width
        visible: true
        anchors.top: emptySquare.bottom
        horizontalAlignment: Text.AlignHCenter
        text: Util.formatPosition(player.position/1000, player.duration/1000)
        color: Theme.highlightColor
        font.pixelSize: player.duration >= 3600000 ? Theme.fontSizeMedium : Theme.fontSizeLarge
        opacity: 1.0
    }

    Label {
        visible: player.sleepTimerRunning
        text: qsTr("Sleep timer: ") + Util.formatDuration(player.sleepTimerRemaining)
        anchors.top: durationLabel.bottom
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        color: Theme.secondaryHighlightColor
        font.pixelSize: Theme.fontSizeExtraSmall
    }
}
