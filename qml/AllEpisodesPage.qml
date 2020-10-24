
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
    id: filteredEpisodes
    allowedOrientations: Orientation.All

    onStatusChanged: pgst.handlePageStatusChange(status)

    Component.onCompleted: {
        episodeListModel.setQuery(episodeListModel.queries.Downloaded);
        episodeListModel.reload();
    }

    BusyIndicator {
        visible: !episodeListModel.ready
        running: visible
        anchors.centerIn: parent
    }

    SilicaListView {
        id: filteredEpisodesList
        anchors.fill: parent

        PullDownMenu {
            EpisodeListFilterItem { id: filterItem; model: episodeListModel }
        }

        VerticalScrollDecorator { flickable: filteredEpisodesList }

        header: PageHeader {
            title: filterItem.currentFilter + ": " + filteredEpisodesList.count
        }

        model: GPodderEpisodeListModel { id: episodeListModel }
        GPodderEpisodeListModelConnections {}

        section.property: 'section'
        section.delegate: SectionHeader {
            text: section
            horizontalAlignment: Text.AlignHCenter
        }

        delegate: EpisodeItem {}

        ViewPlaceholder {
            enabled: filteredEpisodesList.count == 0 && episodeListModel.ready
            text: qsTr("No episodes found")
        }
    }
}
