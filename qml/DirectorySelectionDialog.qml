
/**
 *
 * gPodder QML UI Reference Implementation
 * Copyright (c) 2014, Thomas Perl <m@thp.io>
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

Page {
    id: directorySelectionDialog

    property var model
    property int selectedIndex: -1

    Component.onCompleted: {
        py.call('main.get_directory_providers', [], function (result) {
            directorySelectionDialog.model = result;
        });
    }

    SilicaListView {
        anchors.fill: parent

        header: PageHeader {
            title: 'Select provider'
        }

        model: directorySelectionDialog.model

        delegate: ListItem {
            id: listItem

            highlighted: down || (index == directorySelectionDialog.selectedIndex)

            onClicked: {
                directorySelectionDialog.selectedIndex = index;
                var callback = (function (py) {
                    return (function (url) {
                        py.call('main.subscribe', [url]);
                    });
                })(py);

                if (!modelData.can_search) {
                    pgst.loadPage('Directory.qml', {
                        provider: modelData.label,
                        query: '',
                        callback: callback,
                    }, true);
                } else {
                    pgst.loadPage('DirectoryDialog.qml', {
                        provider: modelData.label,
                        callback: callback,
                    }, true);
                }
            }

            Label {
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    margins: Theme.paddingMedium
                }

                color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                text: modelData.label
            }
        }

        VerticalScrollDecorator { }
    }
}
