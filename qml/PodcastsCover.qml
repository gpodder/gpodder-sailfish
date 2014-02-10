
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

CoverPlaceholder {
    id: podcastsCover

    icon.source: '/usr/share/icons/hicolor/86x86/apps/harbour-org.gpodder.sailfish.png'
    property string _info_text: 'gPodder'
    text: refreshingIndicator.visible ? '' : _info_text

    function update_stats() {
        py.call('main.get_stats', [], function (result) {
            podcastsCover._info_text = Util.format(
                '{podcasts} podcasts\n' +
                '{episodes} episodes\n' +
                '{newEpisodes} new episodes\n' +
                '{downloaded} downloaded',
                result);
        });
    }

    Connections {
        target: py
        onUpdateStats: podcastsCover.update_stats();
        onReadyChanged: {
            if (py.ready) {
                podcastsCover.update_stats();
            }
        }
    }

    BusyIndicator {
        id: refreshingIndicator
        visible: running
        running: py.refreshing
        anchors.centerIn: parent

        NumberAnimation on rotation {
            from: 0; to: 360
            duration: 2000
            running: py.refreshing
            loops: Animation.Infinite
        }
    }
}
