
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
    id: podcastsPage

    SilicaListView {
        id: podcastList
        anchors.fill: parent

        VerticalScrollDecorator { flickable: podcastList }

        PullDownMenu {
            busy: py.refreshing

            MenuItem {
                text: 'About'
                onClicked: pgst.loadPage('AboutPage.qml');
            }

            MenuItem {
                text: 'Filter episodes'
                onClicked: pgst.loadPage('AllEpisodesPage.qml');
            }

            MenuItem {
                text: py.refreshing ? 'Checking for new episodes...' : 'Check for new episodes'
                enabled: podcastListModel.count > 0 && !py.refreshing
                onClicked: py.call('main.check_for_episodes');
            }
        }

        PushUpMenu {
            MenuItem {
                text: 'Add new podcast'
                onClicked: pgst.loadPage('Subscribe.qml');
            }

            MenuItem {
                text: 'Search gpodder.net'
                onClicked: pgst.loadPage('DirectoryDialog.qml');
            }
        }

        header: PageHeader {
            title: 'Subscriptions'
        }

        section.property: 'section'
        section.delegate: SectionHeader {
            text: section
            horizontalAlignment: Text.AlignHCenter
        }

        model: podcastListModel

        delegate: PodcastItem {
            onClicked: pgst.loadPage('EpisodesPage.qml', {'podcast_id': id, 'title': title});
        }

        ViewPlaceholder {
            enabled: podcastListModel.count == 0 && py.ready
            text: 'No subscriptions'
        }
    }
}

