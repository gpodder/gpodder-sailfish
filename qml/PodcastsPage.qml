
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

import 'util.js' as Util

SlidePage {
    id: podcastsPage
    hasPull: true

    function reload() {
        loading.visible = true;
        py.call('main.load_podcasts', [], function (podcasts) {
            Util.updateModelFrom(podcastListModel, podcasts);
            loading.visible = false;
        });
    }

    Component.onCompleted: {
        reload();

        py.setHandler('podcast-list-changed', podcastsPage.reload);

        py.setHandler('updating-podcast', function (podcast_id) {
            for (var i=0; i<podcastListModel.count; i++) {
                var podcast = podcastListModel.get(i);
                if (podcast.id == podcast_id) {
                    podcastListModel.setProperty(i, 'updating', true);
                    break;
                }
            }
        });

        py.setHandler('updated-podcast', function (podcast) {
            for (var i=0; i<podcastListModel.count; i++) {
                if (podcastListModel.get(i).id == podcast.id) {
                    podcastListModel.set(i, podcast);
                    break;
                }
            }
        });
    }

    Component.onDestruction: {
        py.setHandler('podcast-list-changed', undefined);
        py.setHandler('updating-podcast', undefined);
        py.setHandler('updated-podcast', undefined);
    }

    PullMenu {
        PullMenuItem {
            source: 'images/play.png'
            onClicked: {
                pgst.loadPage('PlayerPage.qml');
                podcastsPage.unPull();
            }
        }

        PullMenuItem {
            source: 'images/search.png'
            onClicked: {
                podcastsPage.unPull();
                py.call('main.check_for_episodes');
            }
        }

        PullMenuItem {
            source: 'images/subscriptions.png'
            onClicked: {
                pgst.loadPage('Subscribe.qml');
                podcastsPage.unPull();
            }
        }
    }

    PLabel {
        id: loading
        anchors.centerIn: parent
        text: 'Loading'
    }

    PListView {
        id: podcastList
        title: 'Subscriptions'

        section.property: 'section'
        section.delegate: SectionHeader { text: section }

        model: ListModel { id: podcastListModel }

        delegate: PodcastItem {
            onClicked: pgst.loadPage('EpisodesPage.qml', {'podcast_id': id, 'title': title});
        }
    }
}

