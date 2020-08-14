
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

import 'common/util.js' as Util

Page {
    id: detailPage
    allowedOrientations: Orientation.All

    property int episode_id
    property string title
    property string description
    property string metadata
    property string link
    property bool ready: false
    property var chapters: ([])
    property string episode_art
    property string cover_art
    property string title_char

    onStatusChanged: pgst.handlePageStatusChange(status)

    Component.onCompleted: {
        py.call('main.show_episode', [episode_id], function (episode) {
            detailPage.title = episode.title;
            detailPage.description = episode.description;
            detailPage.metadata = episode.metadata;
            detailPage.chapters = episode.chapters;
            detailPage.link = episode.link;
            detailPage.ready = true;
        });
    }

    BusyIndicator {
        visible: !detailPage.ready
        running: visible
        anchors.centerIn: parent
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Visit website")
                onClicked: Qt.openUrlExternally(detailPage.link);
                enabled: detailPage.link != ''
            }
        }

        VerticalScrollDecorator { flickable: flickable }

        contentWidth: detailColumn.width
        contentHeight: detailColumn.height + detailColumn.spacing

        Column {
            id: detailColumn

            width: detailPage.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("Episode details")
            }

            CustomExpander {
                width: parent.width
                expandedHeight: width

                ArtArea {
                    id: coverImage
                    width: parent.width
                    height: width
                }
            }

            Label {
                text: detailPage.title
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
                text: detailPage.metadata

                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor

                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingMedium
                }

                wrapMode: Text.WordWrap
            }

            CustomExpander {
                id: chaptersExpander
                visible: detailPage.chapters.length > 0

                width: parent.width
                expandedHeight: chaptersColumn.childrenRect.height

                Column {
                    id: chaptersColumn

                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: Theme.paddingMedium
                    }

                    Item { height: Theme.paddingMedium; width: parent.width }

                    Label {
                        text: qsTr("Chapters")
                        anchors {
                            left: parent.left
                        }
                        color: Theme.highlightColor
                    }

                    Repeater {
                        model: detailPage.chapters

                        delegate: ListItem {
                            enabled: false
                            contentHeight: Theme.itemSizeExtraSmall

                            Label {
                                id: durationLabel

                                anchors {
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                }

                                text: Util.formatDuration(modelData.start)
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.secondaryColor
                            }

                            Label {
                                id: titleLabel

                                anchors {
                                    left: durationLabel.right
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: Theme.paddingMedium
                                    right: parent.right
                                }

                                width: parent.width
                                text: modelData.title
                                color: Theme.primaryColor
                                truncationMode: TruncationMode.Fade
                            }
                        }
                    }
                }
            }

            Label {
                text: qsTr("Shownotes")
                color: Theme.highlightColor

                // Only show if we also have a chapters list
                visible: chaptersExpander.visible

                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingMedium
                }
            }

            Label {
                textFormat: Text.StyledText
                text: detailPage.description
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

