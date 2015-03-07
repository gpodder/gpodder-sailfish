
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

import 'common/util.js' as Util

Page {
    id: chapterSelector
    allowedOrientations: Orientation.All

    property var model
    property var player

    SilicaListView {
        anchors.fill: parent

        header: PageHeader {
            title: 'Chapters'
        }

        model: chapterSelector.model

        delegate: ListItem {
            id: listItem
            property bool inThePast: player.position > thisChapterStart && !currentItem
            property real thisChapterStart: modelData.start * 1000
            property real nextChapterStart: {
                if (index < chapterSelector.model.length - 1) {
                    return chapterSelector.model[index + 1].start * 1000;
                } else {
                    return player.duration + 1;
                }
            }
            property real chapterDuration: nextChapterStart - thisChapterStart
            property real chapterProgress: (player.position - thisChapterStart) / chapterDuration
            property bool currentItem: player.position >= modelData.start * 1000 && player.position < nextChapterStart

            highlighted: down || currentItem

            onClicked: {
                chapterSelector.player.seekAndSync(modelData.start * 1000);
                pageStack.pop();
            }

            Rectangle {
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                }

                height: parent.height * 0.2
                width: parent.width * chapterProgress

                visible: listItem.currentItem
                color: player.playing ? Theme.highlightColor : Theme.secondaryHighlightColor
                opacity: .5
            }

            Label {
                id: timeLabel

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    margins: Theme.paddingMedium
                }

                color: listItem.highlighted ? Theme.highlightColor : Theme.secondaryColor
                text: Util.formatDuration(modelData.start)
                font.pixelSize: Theme.fontSizeSmall
            }

            Label {
                id: titleLabel

                anchors {
                    left: timeLabel.right
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: Theme.paddingMedium
                }

                color: listItem.highlighted ? Theme.highlightColor : (listItem.inThePast ? Theme.secondaryColor : Theme.primaryColor)
                text: modelData.title
                truncationMode: TruncationMode.Fade
            }
        }

        VerticalScrollDecorator { }
    }
}
