
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
    id: episodeListModel

    property int podcast_id: -1

    property bool changeConfig: false

    property var queries: ({
        All: '',
        Fresh: 'new or downloading',
        Downloaded: 'downloaded or downloading',
        UnplayedDownloads: 'downloaded and not played',
        FinishedDownloads: 'downloaded and finished',
        HideDeleted: 'not deleted',
        Deleted: 'deleted',
        ShortDownloads: 'downloaded and min > 0 and min < 10',
        TextSearch: '/.*%s.*/i'
    })

    property var filters: ([
        { label: qsTr("All"), query: episodeListModel.queries.All, hasParameters:false },
        { label: qsTr("Fresh"), query: episodeListModel.queries.Fresh, hasParameters:false },
        { label: qsTr("Downloaded"), query: episodeListModel.queries.Downloaded, hasParameters:false },
        { label: qsTr("Unplayed downloads"), query: episodeListModel.queries.UnplayedDownloads, hasParameters:false },
        { label: qsTr("Finished downloads"), query: episodeListModel.queries.FinishedDownloads, hasParameters:false },
        { label: qsTr("Hide deleted"), query: episodeListModel.queries.HideDeleted, hasParameters:false },
        { label: qsTr("Deleted episodes"), query: episodeListModel.queries.Deleted, hasParameters:false },
        { label: qsTr("Short downloads (< 10 min)"), query: episodeListModel.queries.ShortDownloads, hasParameters:false },
        { label: qsTr("Includes Text: %s"), query: episodeListModel.queries.TextSearch, hasParameters:true, searchTerm: ""}
    ])

    property bool ready: false
    property int currentFilterIndex: 0
    property string currentCustomQuery: queries.All


    function getFormattedLabel(i){
        if(i === undefined){
            i = currentFilterIndex
        }
        console.assert(i>=0&&i<filters.length, "invalid filter label request")
        if(filters[i].hasParameters){
            return filters[i].label.replace("%s",filters[i].searchTerm);
        }else{
            return filters[i].label;
        }
    }

    function forEachEpisode(callback) {
        // Go from bottom up (= chronological order)
        for (var i=count-1; i>=0; i--) {
            callback(get(i));
        }
    }

    function setQueryFromIndex(index) {
        setQueryEx(filters[index].query,true);
    }

    function setQueryFromConfigUpdate(query) {
        setQueryEx(query, false);
    }

    function setQuery(query) {
        setQueryEx(query, true);
    }

    function setQueryEx(query, update) {
        console.info(podcast_id,"changing query from '",currentCustomQuery,"' to '",query,"',")
        if(ready && query === currentCustomQuery && !filters[currentFilterIndex].hasParameters){
            console.debug(podcast_id, "filter already selected, skipping...");
            return;
        }
        for (var i=0; i<filters.length; i++) {
            if (filters[i].query === query) {                
                currentCustomQuery = query;
                if (update && changeConfig) {
                   updateConfig();
                }
                currentFilterIndex = i;
                reload();
                return;
            }
        }
        console.error("could not find query: ",query);
    }

    function updateConfig(){
        console.info("saving selected filter: '",currentCustomQuery,"'.")
         py.call('main.set_config_value', ['ui.qml.episode_list.filter_eql', currentCustomQuery]);
    }

    function loadAllEpisodes(callback) {
        episodeListModel.podcast_id = -1;
        reload(callback);
    }

    function loadEpisodes(podcast_id, callback) {
        episodeListModel.podcast_id = podcast_id;
        reload(callback);
    }

    function reload(callback) {
        var query = filters[currentFilterIndex].query;
        if(filters[currentFilterIndex].hasParameters){//text search
            query = query.replace("%s",filters[currentFilterIndex].searchTerm)
        }

        console.info(podcast_id, "reloading with query: '",query,"'.")

        ready = false;
        py.call('main.load_episodes', [podcast_id, query], function (episodes) {
            Util.updateModelFrom(episodeListModel, episodes);
            episodeListModel.ready = true;
            if (callback !== undefined) {
                callback();
            }
        });
    }
}
