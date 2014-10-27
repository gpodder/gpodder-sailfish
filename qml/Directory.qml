
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

Page {
    id: directory

    property string provider
    property string query: '-'
    property var callback

    Component.onCompleted: {
        if (directory.query !== '-') {
            directory.start(directory.provider, directory.query, directory.callback);
        }
    }

    function start(provider, query, callback) {
        directory.provider = provider;
        directory.callback = callback;
        directorySearchModel.search(query, function() {
            busyIndicator.visible = false;
        });
    }

    SilicaListView {
        anchors.fill: parent

        header: PageHeader {
            title: directory.provider
        }

        VerticalScrollDecorator { }

        model: GPodderDirectorySearchModel { id: directorySearchModel; provider: directory.provider }

        delegate: DirectoryItem {
            onClicked: {
                directory.callback(url);
                pageStack.pop();
            }
        }
    }

    BusyIndicator {
        id: busyIndicator
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        visible: true
        running: visible
    }
}
