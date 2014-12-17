
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

import 'common/util.js' as Util


Column {
    anchors {
        left: parent.left
        right: parent.right
        verticalCenter: parent.verticalCenter
        margins: Theme.paddingSmall
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: Theme.fontSizeSmall
        text: Util.formatPosition(player.position/1000, player.duration/1000)
        color: Theme.primaryColor
    }

    Label {
        visible: player.sleepTimerRunning
        text: 'Sleep timer: ' + Util.formatDuration(player.sleepTimerRemaining)

        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        color: Theme.secondaryHighlightColor
        wrapMode: Text.Wrap
        font.pixelSize: Theme.fontSizeExtraSmall
    }

    Label {
        text: player.episode_title
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        color: Theme.highlightColor
        wrapMode: Text.Wrap
    }

    Label {
        text: player.podcast_title
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        color: Theme.secondaryHighlightColor
        wrapMode: Text.Wrap
        font.pixelSize: Theme.fontSizeExtraSmall
    }
}
