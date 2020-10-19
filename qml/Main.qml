
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
import Nemo.Configuration 1.0

import 'common'
import 'utils'

PodcastsPage {
    id: pgst
    property bool ready: false

    property var playerPage: undefined
    property var cover: CoverContainer { }

    onStatusChanged: pgst.handlePageStatusChange(status)

    function handlePageStatusChange(st) {
        if (st === PageStatus.Active) {
            createPlayerPage();
        }
    }

    function createPlayerPage() {
        if (player.episode !== 0) {
            if (playerPage === undefined) {
                playerPage = Qt.createComponent('PlayerPage.qml').createObject(pgst);
            }
            pageStack.pushAttached(playerPage);
        }
    }

    function update(page, x) {
        var index = -1;
        for (var i=0; i<children.length; i++) {
            if (children[i] === page) {
                index = i;
                break;
            }
        }

        children[index-1].opacity = x / width;
    }

    GPodderCore {
        id: py
        progname: 'harbour-org.gpodder.sailfish'
    }

    GPodderPlayback {
        id: player
        onPlayerCreated: pgst.createPlayerPage();
    }
    
    MprisPlayer {}
    MediaKeys {}

    ConnectionUtil {
        id: connectionUtil
    }

    GPodderPodcastListModel { id: podcastListModel }
    GPodderPodcastListModelConnections {}

    function loadPage(filename, properties, replace) {
        var component = Qt.createComponent(filename);
        if (component.status !== Component.Ready) {
            console.log('Error loading ' + filename + ':' +
                component.errorString());
        }

        if (properties === undefined) {
            properties = {};
        }

        if (replace !== true) {
            pageStack.push(component.createObject(pgst, properties));
        } else {
            pageStack.replace(component.createObject(pgst, properties));
        }
    }

    BusyIndicator {
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        visible: !py.ready
        running: visible
    }

    ConfigurationValue {
        id: configCellularDownloadsEnabled
        key: "/apps/ControlPanel/gpodder/cellularDownloadsEnabled"
        defaultValue: false
    }

}
