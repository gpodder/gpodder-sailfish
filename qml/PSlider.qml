
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

Rectangle {
    id: slider

    property real value
    property real min: 0.0
    property real max: 1.0

    signal valueChangeRequested(real newValue)

    color: '#aa000000'

    height: 50 * pgst.scalef

    MouseArea {
        anchors.fill: parent
        onClicked: slider.valueChangeRequested(min + (max - min) * (mouse.x / width))
    }

    Rectangle {
        height: parent.height * 0.9
        width: height

        color: '#aaffffff'

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: parent.width * (parent.value - parent.min) / (parent.max - parent.min)
        }
    }
}
