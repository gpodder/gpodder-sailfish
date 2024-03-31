
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
    id: filterSelector
    allowedOrientations: Orientation.All

    property var model
    property int selectedIndex: model.currentFilterIndex

    SilicaListView {
        anchors.fill: parent

        header: PageHeader {
            title: qsTr("Filter episode list")
        }

        model: {
            var result = [];
            for (var i in filterSelector.model.filters) {
                result.push(filterSelector.model.filters[i].label);
            }
            return result;
        }

        delegate: ListItem {
            id: listItem

            highlighted: down || (index == filterSelector.selectedIndex)

            onClicked: {
                filterSelector.model.currentFilterIndex = index;
                filterSelector.model.reload();
                pageStack.pop();
            }

            Label {
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    margins: Theme.paddingMedium
                }

                color: listItem.highlighted ? Theme.highlightColor: Theme.primaryColor
                text: modelData
            }
        }

        VerticalScrollDecorator { }
    }
}
