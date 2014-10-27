
/**
 *
 * gPodder QML UI Reference Implementation
 * Copyright (c) 2013, 2014, Thomas Perl <m@thp.io>
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

ListItem {
    id: directoryItem

    contentHeight: Theme.itemSizeMedium
    height: contentHeight

    anchors {
        left: parent.left
        right: parent.right
    }

    Image {
        id: cover
        opacity: image && status == Image.Ready
        Behavior on opacity { FadeAnimation { } }

        anchors {
            left: parent.left
            leftMargin: Theme.paddingSmall
            verticalCenter: parent.verticalCenter
        }

        sourceSize.width: width
        sourceSize.height: height

        width: Theme.iconSizeMedium
        height: Theme.iconSizeMedium

        source: image
    }

    Rectangle {
        opacity: 1 - cover.opacity

        anchors.fill: cover
        color: Theme.rgba(Theme.highlightColor, 0.5)

        clip: true

        Label {
            anchors.centerIn: parent

            font.pixelSize: parent.height * 0.8
            text: title[0]
            color: Theme.highlightColor
        }
    }

    Label {
        anchors {
            left: cover.right
            leftMargin: Theme.paddingSmall
            rightMargin: subs.text ? Theme.paddingSmall : 0
            right: subs.left
            verticalCenter: parent.verticalCenter
        }

        truncationMode: TruncationMode.Fade
        text: title
    }

    Label {
        id: subs

        anchors {
            right: parent.right
            rightMargin: Theme.paddingSmall
            verticalCenter: parent.verticalCenter
        }

        text: (subscribers > 0) ? subscribers : ''
    }
}
