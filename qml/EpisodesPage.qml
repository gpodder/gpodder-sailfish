
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

import 'common'
import 'common/util.js' as Util

Page {
    id: episodesPage
    allowedOrientations: Orientation.All

    property int podcast_id
    property string title

    onStatusChanged: pgst.handlePageStatusChange(status)

    width: parent.width
    height: parent.height

    RemorsePopup { id: remorse }

    Component.onCompleted: {
        singlePodcastEpisodesModel.podcast_id = podcast_id;
        singlePodcastEpisodesModel.setQuery(singlePodcastEpisodesModel.queries.All);
    }

    BusyIndicator {
        visible: !singlePodcastEpisodesModel.ready
        running: visible
        anchors.centerIn: parent
    }

    SilicaListView {
        id: episodeList

        VerticalScrollDecorator { flickable: episodeList }

        anchors.fill: parent
        header: BackgroundItem {
            height: pageHeader.height
            width: parent.width
            PageHeader {
                id: pageHeader
                title: episodesPage.title
            }

            onClicked: {
                pgst.loadPage('PodcastDetail.qml', {podcast_id: episodesPage.podcast_id, title: episodesPage.title});
            }
        }

        model: GPodderEpisodeListModel { id: singlePodcastEpisodesModel }
        GPodderEpisodeListModelConnections {
            model: singlePodcastEpisodesModel
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Unsubscribe")
                onClicked: {
                    remorse.execute("Unsubscribing", function() {
                        py.call('main.unsubscribe', [episodesPage.podcast_id]);
                        if (pageStack.currentPage == episodesPage) {
                            pageStack.pop();
                        }
                    })
                }
            }

            MenuItem {
                text: qsTr("Mark episodes as old")
                onClicked: {
                    py.call('main.mark_episodes_as_old', [episodesPage.podcast_id]);
                }
            }

            MenuItem {
                text: qsTr("Enqueue episodes in player")
                onClicked: {
                    var startPlayback = Util.atMostOnce(function () {
                        if (!player.isPlaying) {
                            player.jumpToQueueIndex(0);
                        }
                    });

                    singlePodcastEpisodesModel.forEachEpisode(function (episode) {
                        player.enqueueEpisode(episode.id, startPlayback);
                    });
                }
            }

            EpisodeListFilterItem { model: singlePodcastEpisodesModel }
        }

        delegate: EpisodeItem {}

        ViewPlaceholder {
            enabled: episodeList.count == 0 && singlePodcastEpisodesModel.ready
            text: qsTr("No episodes found")
        }
    }
}

