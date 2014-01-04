
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

import 'constants.js' as Constants

Item {
    id: slidePageHeader
    property string title

    width: parent.width
    height: Constants.layout.header.height * pgst.scalef

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: slidePageHeader.height * 0.15
        }

        height: slidePageHeader.height * 0.7
        color: '#33000000'
    }

    Text {
        anchors {
            left: parent.left
            right: parent.right
            rightMargin: 20 * pgst.scalef
            leftMargin: 70 * pgst.scalef
            verticalCenter: parent.verticalCenter
        }

        color: 'white'
        horizontalAlignment: Text.AlignRight
        font.pixelSize: parent.height * .4 * pgst.scalef
        elide: Text.ElideRight
        text: parent.title
    }
}

