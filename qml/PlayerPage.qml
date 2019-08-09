
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
import 'common/util.js' as Util

Page {
    id: playerPage
    allowedOrientations: Orientation.All

    SilicaFlickable {
        id: flickable
        anchors.fill: parent

        contentWidth: column.width
        contentHeight: column.height + column.spacing

        PullDownMenu {
            PlayerChaptersItem {
                model: player.episode_chapters
            }

            MenuItem {
                text: player.sleepTimerRunning ? qsTr("Stop sleep timer") : qsTr("Sleep timer")
                onClicked: {
                    if (player.sleepTimerRunning) {
                        player.stopSleepTimer();
                    } else {
                        pageStack.push('SleepTimerDialog.qml', { player: player });
                    }
                }
            }

            MenuItem {
                text: qsTr("Clear play queue")
                enabled: playQueueRepeater.count > 0
                onClicked: player.clearQueue()
            }
        }

        Column {
            id: column

            width: playerPage.width

            PageHeader {
                title: qsTr("Player")
            }
            
            SectionHeader {
				text: qsTr("Now playing")
				visible: player.episode!=0
			}
            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
                text: player.podcast_title
                horizontalAlignment: Text.AlignHCenter
                color: Theme.secondaryHighlightColor
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
            }


            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }

                truncationMode: TruncationMode.Fade
                horizontalAlignment: Text.AlignHCenter
                text: player.episode_title
                color: Theme.rgba(Theme.highlightColor, 0.7)
                font.pixelSize: Theme.fontSizeSmall
            }

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }

                visible: player.sleepTimerRunning

                truncationMode: TruncationMode.Fade
                horizontalAlignment: Text.AlignRight
                text: qsTr("Sleep timer: ") + Util.formatDuration(player.sleepTimerRemaining)
                color: Theme.rgba(Theme.highlightColor, 0.7)
                font.pixelSize: Theme.fontSizeExtraSmall
            }

            Connections {
                target: player
                onPositionChanged: {
                    if (!positionSlider.down) {
                        positionSlider.value = player.position;
                    }
                }
            }

            Item {
                width: parent.width
                height: Theme.paddingSmall
            }

            Label {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                font.pixelSize: Theme.fontSizeLarge
                text: Util.formatPosition(positionSlider.value/1000, player.duration/1000)
                color: positionSlider.highlighted ? Theme.highlightColor : Theme.primaryColor
            }

            Item {
                width: parent.width
                height: Theme.paddingSmall
            }

            Slider {
                id: positionSlider
                width: parent.width

                value: player.position
                minimumValue: 0
                maximumValue: player.duration
                onDownChanged: {
                    if (!down) {
                        player.seekAndSync(sliderValue)
                    }
                }
            }

            Row {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    margins: Theme.paddingMedium
                }

                height: Theme.itemSizeLarge
                spacing: Theme.paddingMedium

                IconMenuItem {
                    text: qsTr("- 1 min")
                    icon.source: 'image://theme/icon-m-previous'

                    GPodderAutoFire {
                        running: parent.down
                        onFired: player.seekAndSync(player.position - 1000 * 60)
                    }
                }

                IconMenuItem {
                    text: qsTr("- 10 sec")
                    icon.source: 'image://theme/icon-m-previous'
                    GPodderAutoFire {
                        running: parent.down
                        onFired: player.seekAndSync(player.position - 1000 * 10)
                    }
                }

                IconMenuItem {
                    text: player.isPlaying ? qsTr("Pause") : qsTr("Play")
                    onClicked: {
                        if (player.isPlaying) {
                            player.pause();
                        } else {
                            player.play();
                        }
                    }
                    icon.source: player.isPlaying ? 'image://theme/icon-m-pause' : 'image://theme/icon-m-play'
                }

                IconMenuItem {
                    text: qsTr("+ 10 sec")
                    icon.source: 'image://theme/icon-m-next'
                    GPodderAutoFire {
                        running: parent.down
                        onFired: player.seekAndSync(player.position + 1000 * 10)
                    }
                }

                IconMenuItem {
                    text: qsTr("+ 1 min")
                    icon.source: 'image://theme/icon-m-next'
                    GPodderAutoFire {
                        running: parent.down
                        onFired: player.seekAndSync(player.position + 1000 * 60)
                    }
                }
            }

            SectionHeader {
                text: qsTr("Queue")
                visible: playQueueRepeater.count > 0
            }

            Repeater {
                id: playQueueRepeater
                model: player.queue
                property Item contextMenu

                property var queueConnections: Connections {
                    target: player

                    onQueueUpdated: {
                        playQueueRepeater.model = player.queue;
                    }
                }

                ListItem {
                    id: playQueueListItem

                    width: parent.width

                    menu: ContextMenu {
                        MenuItem {
                            text: qsTr("Remove from queue")
                            onClicked: player.removeQueueIndex(index);
                        }
                    }

                    Label {
                        anchors {
                            left: parent.left
                            right: parent.right
                            margins: Theme.paddingMedium
                            verticalCenter: parent.verticalCenter
                        }

                        text: modelData.title
                        truncationMode: TruncationMode.Fade
                    }

                    onClicked: {
                        player.jumpToQueueIndex(index);
                    }
                }
            }
        }
    }
}
