
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
    allowedOrientations: Orientation.All

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
                text: qsTr("Copy feed URL")
                onClicked: Clipboard.text = podcastDetail.url;
            }

            MenuItem {
                text: qsTr("Visit website")
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
                title: qsTr("Podcast details")
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
            ListItem {
                Label {
                    id: sectionTitle
                    text: qsTr("Section: ")

                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.highlightColor

                    anchors {
                        left: parent.left
                        margins: Theme.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }

                    wrapMode: Text.WordWrap
                }
                Label {
                    id: sectionField
                    text: podcastDetail.section

                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.primaryColor

                    anchors {
                        left: sectionTitle.right
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                }

                onClicked: openMenu()

                menu: ContextMenu {
                    container: sectionField
                    MenuItem {
                        text: qsTr("Edit Section")
                        onClicked: pageStack.push(editPodcastPage)
                    }
                }
            }

            Label {
                textFormat: Text.StyledText
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
    Component {
        id: editPodcastPage

        Dialog {
            id: sectionDialog
            canAccept: sectionFieldInput.text != podcastDetail.section
            onAccepted: {
                py.call('main.change_section', [podcast_id, sectionFieldInput.text])
                podcastDetail.section = sectionFieldInput.text
                pageStack.pop()
            }

            Column {
                anchors.fill: parent
                DialogHeader {
                    title: qsTr('Edit Section')
                    acceptText: qsTr('Save')
                }

                TextField {
                   id: sectionFieldInput
                   text: podcastDetail.section

                   anchors {
                       left: parent.left
                       right: parent.right
                   }
                   EnterKey.enabled: text.length > 0 && text != podcastDetail.section
                   EnterKey.onClicked: sectionDialog.accept()
                }
            }
        }
    }
}

