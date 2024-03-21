
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
    allowedOrientations: Orientation.All

    SilicaListView {
        id: podcastList
        anchors.fill: parent

        VerticalScrollDecorator { flickable: podcastList }

        PullDownMenu {
            busy: py.refreshing

            MenuItem {
                text: qsTr("Settings")
                onClicked: pgst.loadPage('SettingsPage.qml');
            }

            MenuItem {
                text: qsTr("Filter episodes")
                onClicked: pgst.loadPage('AllEpisodesPage.qml');
            }

            MenuItem {
                text: py.refreshing ? qsTr("Checking for new episodes...") : qsTr("Check for new episodes")
                enabled: podcastListModel.count > 0 && !py.refreshing
                onClicked: py.call('main.check_for_episodes');
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr("Add new podcast")
                onClicked: pgst.loadPage('Subscribe.qml');
            }

            MenuItem {
                text: qsTr("Discover new podcasts")
                onClicked: pgst.loadPage('DirectorySelectionDialog.qml');
            }

            MenuItem {
                text: qsTr("Import/Export OPML")
                onClicked: pgst.loadPage('ImportOPML.qml')
            }
        }

        header: PageHeader {
            title: qsTr("Subscriptions")
        }

        section.property: 'section'
        section.delegate: SectionHeader {
            text: section
            horizontalAlignment: Text.AlignHCenter
        }

        model: podcastListModel

        BusyIndicator {
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            visible: !podcastListModel.initialized
            running: visible
        }

        delegate: PodcastItem {
            onClicked: pgst.loadPage('EpisodesPage.qml', {'podcast_id': id, 'title': title});
        }

        ViewPlaceholder {
            enabled: podcastListModel.count === 0 && podcastListModel.initialized
            text: qsTr("No subscriptions")
        }
    }
}

