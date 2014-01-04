
/**
 *
 * gPodder QML UI Reference Implementation
 * Copyright (c) 2013, Thomas Perl <m@thp.io>
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

ButtonArea {
    id: podcastItem

    transparent: true

    height: 100 * pgst.scalef
    anchors {
        left: parent.left
        right: parent.right
    }

    Image {
        id: cover
        visible: !updating

        anchors {
            left: parent.left
            leftMargin: 10 * pgst.scalef
            verticalCenter: parent.verticalCenter
        }

        sourceSize.width: width
        sourceSize.height: height

        width: 80 * pgst.scalef
        height: 80 * pgst.scalef

        source: coverart
    }

    PBusyIndicator {
        anchors.centerIn: cover
        visible: updating
    }

    PLabel {
        anchors {
            left: cover.right
            leftMargin: 10 * pgst.scalef
            rightMargin: 10 * pgst.scalef
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        elide: Text.ElideRight
        text: title
    }
}

