
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

Item {
    height: 64 * pgst.scalef
    width: 64 * pgst.scalef

    Image {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 30*Math.abs(Math.sin(phase)) * pgst.scalef
        }

        transform: Scale {
            origin.x: 32 * pgst.scalef
            origin.y: 32 * pgst.scalef
            xScale: 1.0 - 0.3 * (1.0 - Math.abs(Math.sin(phase)))
        }

        source: 'images/gpodder.png'
    }

    property real phase: 0

    PropertyAnimation on phase {
        loops: Animation.Infinite
        duration: 2000
        running: parent.visible
        from: 0
        to: 2*Math.PI
    }
}

