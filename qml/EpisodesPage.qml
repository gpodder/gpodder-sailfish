
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
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.0

import 'common/util.js' as Util
import 'constants.js' as Constants

Page {
    id: episodesPage

    property int podcast_id
    property string title

    width: parent.width
    height: parent.height

    RemorsePopup { id: remorse }

    Component.onCompleted: {
        py.call('main.load_episodes', [podcast_id], function (episodes) {
            Util.updateModelFrom(episodeListModel, episodes);
        });
    }

    Connections {
        target: py
        onDownloadProgress: {
            Util.updateModelWith(episodeListModel, 'id', episode_id,
                {'progress': progress});
        }
        onDownloaded: {
            Util.updateModelWith(episodeListModel, 'id', episode_id,
                {'progress': 0, 'downloadState': Constants.state.downloaded});
        }
        onDeleted: {
            Util.updateModelWith(episodeListModel, 'id', episode_id,
                {'downloadState': Constants.state.deleted, 'isNew': false});
        }
        onIsNewChanged: {
            Util.updateModelWith(episodeListModel, 'id', episode_id,
                {'isNew': is_new});
        }
        onStateChanged: {
            Util.updateModelWith(episodeListModel, 'id', episode_id,
                {'downloadState': state});
        }
    }

    SilicaListView {
        id: episodeList

        VerticalScrollDecorator { flickable: episodeList }

        anchors.fill: parent
        header: PageHeader {
            title: episodesPage.title
        }

        model: ListModel { id: episodeListModel }

        PullDownMenu {
            MenuItem {
                text: 'Now playing'
                onClicked: pgst.loadPage('PlayerPage.qml');
            }

            MenuItem {
                text: 'Unsubscribe'
                onClicked: {
                    remorse.execute("Unsubscribing", function() {
                        py.call('main.unsubscribe', [episodesPage.podcast_id]);
                        if (pageStack.currentPage == episodesPage) {
                            pageStack.pop();
                        }
                    })
                }
            }
        }

        delegate: EpisodeItem {}

        ViewPlaceholder {
            enabled: episodeList.count == 0
            text: 'No episodes'
        }
    }
}

