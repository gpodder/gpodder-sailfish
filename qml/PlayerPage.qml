
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
    id: playerPage

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
                text: player.isPlaying ? 'Pause': 'Play'
                onClicked: {
                    if (player.isPlaying) {
                        player.pause();
                    } else {
                        player.play();
                    }
                }
            }
        }

        Column {
            id: column

            width: playerPage.width

            PageHeader {
                title: 'Now playing'
            }

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }

                truncationMode: TruncationMode.Fade
                horizontalAlignment: Text.AlignRight
                text: player.episode_title
                color: Theme.rgba(Theme.highlightColor, 0.7)
                font.pixelSize: Theme.fontSizeSmall
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
                height: Theme.itemSizeSmall
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
                height: Theme.paddingMedium
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

            Item {
                width: parent.width
                height: Theme.itemSizeLarge
            }

            TimePicker {
                hourMode: DateTime.TwentyFourHours
                anchors.horizontalCenter: parent.horizontalCenter

                property int oldHour: hour
                property int oldMinute: minute

                onHourChanged: {
                    var diff = hour - oldHour;
                    if (diff > 12) {
                        diff -= 24;
                    } else if (diff < -12) {
                        diff += 24;
                    }
                    player.seekAndSync(player.position + 1000 * 60 * diff);
                    oldHour = hour;
                }

                onMinuteChanged: {
                    var diff = minute - oldMinute;
                    if (diff > 30) {
                        diff -= 60;
                    } else if (diff < -30) {
                        diff += 60;
                    }
                    player.seekAndSync(player.position + 1000 * 10 * diff);
                    oldMinute = minute;
                }
            }
        }
    }
}
