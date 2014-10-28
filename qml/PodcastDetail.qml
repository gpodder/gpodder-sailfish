
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
    id: podcastDetail

    property int podcast_id
    property string title
    property string description
    property string link
    property string section
    property string coverart
    property string url

    property bool ready: false

    onStatusChanged: pgst.handlePageStatusChange(status)

    Component.onCompleted: {
        py.call('main.show_podcast', [podcast_id], function (podcast) {
            podcastDetail.title = podcast.title;
            podcastDetail.description = podcast.description;
            podcastDetail.link = podcast.link;
            podcastDetail.section = podcast.section;
            podcastDetail.coverart = podcast.coverart;
            podcastDetail.url = podcast.url;
            podcastDetail.ready = true;
        });
    }

    BusyIndicator {
        visible: !podcastDetail.ready
        running: visible
        anchors.centerIn: parent
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: 'Copy feed URL'
                onClicked: Clipboard.text = podcastDetail.url;
            }

            MenuItem {
                text: 'Visit website'
                onClicked: Qt.openUrlExternally(podcastDetail.link);
                enabled: podcastDetail.link != ''
            }
        }

        VerticalScrollDecorator { flickable: flickable }

        contentWidth: detailColumn.width
        contentHeight: detailColumn.height + detailColumn.spacing

        Column {
            id: detailColumn

            width: podcastDetail.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: 'Podcast details'
            }

            CustomExpander {
                width: parent.width
                expandedHeight: coverImage.height

                Image {
                    id: coverImage
                    source: podcastDetail.coverart
                    fillMode: Image.PreserveAspectFit
                    width: parent.width
                }
            }

            Label {
                text: podcastDetail.title
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor

                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingMedium
                }
            }

            Label {
                visible: text !== ''
                text: podcastDetail.link

                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor

                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingMedium
                }

                wrapMode: Text.WordWrap
            }

            Label {
                text: 'Section: ' + podcastDetail.section

                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor

                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingMedium
                }

                wrapMode: Text.WordWrap
            }

            Label {
                text: podcastDetail.description
                linkColor: Theme.highlightColor
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingMedium
                }
                wrapMode: Text.WordWrap
                onLinkActivated: Qt.openUrlExternally(link)
            }
        }
    }
}

