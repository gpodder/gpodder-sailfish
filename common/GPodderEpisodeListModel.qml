
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

import 'util.js' as Util
import 'constants.js' as Constants

ListModel {
    property int podcast_id: -1
    property var myself: this


    property var queries: ({
        All: '',
        Fresh: 'new or downloading',
        Downloaded: 'downloaded or downloading',
        UnplayedDownloads: 'downloaded and not played',
        FinishedDownloads: 'downloaded and finished',
        HideDeleted: 'not deleted',
        Deleted: 'deleted',
        ShortDownloads: 'downloaded and min > 0 and min < 10',
    })

    property var filters: ([
        { label: qsTr("All"), query: queries.All },
        { label: qsTr("Fresh"), query: queries.Fresh },
        { label: qsTr("Downloaded"), query: queries.Downloaded },
        { label: qsTr("Unplayed downloads"), query: queries.UnplayedDownloads },
        { label: qsTr("Finished downloads"), query: queries.FinishedDownloads },
        { label: qsTr("Hide deleted"), query: queries.HideDeleted },
        { label: qsTr("Deleted episodes"), query: queries.Deleted },
        { label: qsTr("Short downloads (< 10 min)"), query: queries.ShortDownloads },
    ])

    property bool ready: false
    property int currentFilterIndex: -1
    property string currentCustomQuery: queries.All

    function forEachEpisode(callback) {
        // Go from bottom up (= chronological order)
        for (var i=count-1; i>=0; i--) {
            callback(get(i));
        }
    }

    function setQueryFromIndex(index) {
        console.debug("Setting filter index ", index)
        setQueryEx(filters[index].query, true);
    }

    function setQueryFromConfigUpdate(query) {
        setQueryEx(query, false);
    }

    function setQuery(query) {
        setQueryEx(query, true);
    }

    function setQueryEx(query, update) {
        for (var i=0; i<filters.length; i++) {
            if (filters[i].query === query) {
                currentCustomQuery = query;
                currentFilterIndex = i;
                console.debug("found index ", i, " for query '", query, "'");
                if (update && podcast_id === -1) {
                    updateQueryFilterConfig();
                }
                reload();
                return;
            }
        }
        console.warn("Could not find a predefined query for: '",query,"' Resetting to the all-query");
        setQueryFromIndex(0);
    }

    function updateQueryFilterConfig(){
        console.info("saving selected filter: ", currentFilterIndex, "='", currentCustomQuery, "'.")
        py.call('main.set_config_value', ['ui.qml.episode_list.filter_eql', currentCustomQuery])
    }

    function loadAllEpisodes(callback) {
        podcast_id = -1;
        reload(callback);
    }

    function loadEpisodes(podcast, callback) {
        podcast_id = podcast;
        reload(callback);
    }

    function reload(callback) {
        var query;

        if (currentFilterIndex !== -1) {
            query = filters[currentFilterIndex].query;
        } else {
            query = currentCustomQuery;
        }

        myself.ready = false;
        py.call('main.load_episodes', [podcast_id, query], function (episodes) {
            Util.updateModelFrom( myself, episodes);
             myself.ready = true;
            if (callback !== undefined) {
                callback();
            }
        });
    }
}
