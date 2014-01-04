
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

Page {
    id: startPage

    function update_stats() {
        py.call('main.get_stats', [], function (result) {
            stats.text = result;
        });

        py.call('main.get_fresh_episodes_summary', [3], function (episodes) {
            freshEpisodesRepeater.model = episodes;
        });
    }

    Component.onCompleted: {
        py.setHandler('update-stats', startPage.update_stats);
    }

    Component.onDestruction: {
        py.setHandler('update-stats', undefined);
    }

    SilicaFlickable {
        id: startPageFlickable

        PullDownMenu {
            MenuItem {
                text: 'Now playing'
                onClicked: pgst.loadPage('PlayerPage.qml');
            }
            MenuItem {
                text: "Settings"
                onClicked: pgst.loadPage('Settings.qml');
            }
        }

        VerticalScrollDecorator { flickable: startPageFlickable }

        Connections {
            target: pgst
            onReadyChanged: {
                if (pgst.ready) {
                    startPage.update_stats();
                }
            }
        }

        anchors.fill: parent

        contentWidth: startPageColumn.width
        contentHeight: startPageColumn.height + startPageColumn.spacing

        Column {
            id: startPageColumn

            width: startPage.width
            spacing: 20 * pgst.scalef

            PageHeader {
                title: 'gPodder'
            }

            SectionHeader {
                text: 'Subscriptions'
            }

            BackgroundItem {
                id: subscriptionsPane

                onClicked: pgst.loadPage('PodcastsPage.qml');
                width: startPage.width
                height: startPage.height / 5

                Label {
                    id: stats

                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        margins: 20 * pgst.scalef
                    }
                }
            }

            SectionHeader {
                id: freshEpisodesHeader
                text: 'Fresh episodes'
            }

            BackgroundItem {
                id: freshEpisodesPage
                height: startPage.height / 6
                width: parent.width

                onClicked: pgst.loadPage('FreshEpisodes.qml');

                Component.onCompleted: {
                    py.setHandler('refreshing', function (is_refreshing) {
                        refresherButton.visible = !is_refreshing;
                        if (!is_refreshing) {
                            freshEpisodesHeader.text = 'Fresh episodes';
                        }
                    });

                    py.setHandler('refresh-progress', function (pos, total) {
                        freshEpisodesHeader.text = 'Refreshing feeds (' + pos + '/' + total + ')';
                    });
                }

                Row {
                    id: freshRow

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.margins: spacing

                    spacing: 10 * pgst.scalef

                    Repeater {
                        id: freshEpisodesRepeater

                        Image { 
                            source: modelData.coverart
                            sourceSize { width: 80 * pgst.scalef; height: 80 * pgst.scalef }
                            width: 80 * pgst.scalef
                            height: 80 * pgst.scalef

                            /*
                            Label {
                                anchors {
                                    horizontalCenter: parent.horizontalCenter
                                    bottom: parent.bottom
                                }

                                text: modelData.newEpisodes
                            }
                            */
                        }
                    }
                }
            }
        }
    }
}

