
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

import 'constants.js' as Constants

SlidePage {
    id: detailPage

    property int episode_id
    property string title

    Component.onCompleted: {
        label.text = 'Loading...';
        py.call('main.show_episode', [episode_id], function (episode) {
            label.text = episode.description;
        });
    }

    Flickable {
        id: flickable
        anchors.fill: parent

        contentWidth: detailColumn.width
        contentHeight: detailColumn.height + detailColumn.spacing

        Column {
            id: detailColumn

            width: detailPage.width
            spacing: 10 * pgst.scalef

            SlidePageHeader {
                title: detailPage.title
            }

            ButtonArea {
                width: detailPage.width
                height: 100 * pgst.scalef
                onClicked: player.playbackEpisode(detailPage.episode_id)

                PLabel {
                    anchors.centerIn: parent
                    text: 'Play'
                }
            }

            PLabel {
                id: label
                width: parent.width * .8
                font.pixelSize: 30 * pgst.scalef
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
            }
        }
    }
}

