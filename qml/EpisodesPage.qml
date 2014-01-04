
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
import io.thp.pyotherside 1.0

import 'util.js' as Util

SlidePage {
    id: episodesPage

    hasPull: true

    property int podcast_id
    property string title

    width: parent.width
    height: parent.height

    Component.onCompleted: {
        py.call('main.load_episodes', [podcast_id], function (episodes) {
            Util.updateModelFrom(episodeListModel, episodes);
        });
    }

    PullMenu {
        PullMenuItem {
            source: 'images/play.png'
            onClicked: {
                pgst.loadPage('PlayerPage.qml');
                episodesPage.unPull();
            }
        }

        PullMenuItem {
            source: 'images/delete.png'
            onClicked: {
                py.call('main.unsubscribe', [episodesPage.podcast_id]);
                episodesPage.closePage();
            }
        }
    }

    PListView {
        id: episodeList
        title: episodesPage.title
        model: ListModel { id: episodeListModel }

        delegate: EpisodeItem {
            onClicked: pgst.loadPage('EpisodeDetail.qml', {episode_id: id, title: title});
        }
    }
}

