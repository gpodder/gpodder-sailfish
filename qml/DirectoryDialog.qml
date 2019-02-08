
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
import Sailfish.Silica 1.0

Dialog {
    id: directory
    allowedOrientations: Orientation.All

    property string provider
    property var callback

    canAccept: input.text != ''

    acceptDestination: Component { Directory { } }
    acceptDestinationAction: PageStackAction.Replace

    onAccepted: {
        acceptDestinationInstance.start(directory.provider, input.text, directory.callback);
    }

    Column {
        anchors.fill: parent

        DialogHeader {
            title: directory.provider
            acceptText: 'Search'
        }

        TextField {
            id: input
            width: parent.width
            label: qsTr("Search term")
            focus: enabled
            enabled: directory.status == PageStatus.Active
            placeholderText: label
            EnterKey.onClicked: directory.accept()
        }
    }
}
