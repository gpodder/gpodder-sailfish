
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

Rectangle {
    id: page
    color: '#88000000'

    default property alias children: dragging.children
    property alias hasPull: dragging.hasPull
    property alias canClose: dragging.canClose
    property real pullPhase: (x >= 0) ? 0 : (-x / (width / 4))

    function unPull() {
        stacking.fadeInAgain();
    }

    function closePage() {
        stacking.startFadeOut();
    }

    onXChanged: pgst.update(page, x)

    width: parent.width
    height: parent.height

    Stacking { id: stacking }

    Dragging {
        id: dragging
        stacking: stacking

        onPulled: console.log('have pulled it!')
    }

    Rectangle {
        color: 'black'
        anchors.fill: parent

        opacity: page.pullPhase * 0.8

        MouseArea {
            enabled: parent.opacity > 0
            anchors.fill: parent
            onClicked: page.unPull();
        }
    }

    Image {
        anchors {
            right: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: 10 * pgst.scalef
        source: 'images/pageshadow.png'
        opacity: .2
    }

    Image {
        anchors {
            left: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        mirror: true
        width: 10 * pgst.scalef
        source: 'images/pageshadow.png'
        opacity: .2
    }
}

