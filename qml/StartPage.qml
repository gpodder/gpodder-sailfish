
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

SlidePage {
    id: startPage
    canClose: false

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

    Flickable {
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

            SlidePageHeader {
                title: 'gPodder'
            }

            StartPageButton {
                id: subscriptionsPane

                title: 'Subscriptions'
                onClicked: pgst.loadPage('PodcastsPage.qml');

                PLabel {
                    id: stats

                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        margins: 20 * pgst.scalef
                    }
                }

                ButtonArea {
                    anchors {
                        bottom: parent.bottom
                        right: parent.right
                    }

                    transparent: true
                    onClicked: pgst.loadPage('Subscribe.qml');
                    width: subscriptions.width + 2*subscriptions.anchors.margins
                    height: subscriptions.height + 2*subscriptions.anchors.margins

                    Image {
                        id: subscriptions
                        source: 'images/subscriptions.png'

                        anchors {
                            bottom: parent.bottom
                            right: parent.right
                            margins: 20 * pgst.scalef
                        }
                    }
                }
            }

            StartPageButton {
                id: freshEpisodesPage

                title: 'Fresh episodes'
                onClicked: pgst.loadPage('FreshEpisodes.qml');

                Component.onCompleted: {
                    py.setHandler('refreshing', function (is_refreshing) {
                        refresherButtonArea.visible = !is_refreshing;
                        if (!is_refreshing) {
                            freshEpisodesPage.title = 'Fresh episodes';
                        }
                    });

                    py.setHandler('refresh-progress', function (pos, total) {
                        freshEpisodesPage.title = 'Refreshing feeds (' + pos + '/' + total + ')';
                    });
                }

                Row {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 50 * pgst.scalef
                    anchors.leftMargin: 20 * pgst.scalef
                    anchors.left: parent.left
                    spacing: 10 * pgst.scalef

                    Repeater {
                        id: freshEpisodesRepeater

                        Image { 
                            source: modelData.coverart
                            sourceSize { width: 80 * pgst.scalef; height: 80 * pgst.scalef }
                            width: 80 * pgst.scalef
                            height: 80 * pgst.scalef

                            PLabel {
                                anchors {
                                    horizontalCenter: parent.horizontalCenter
                                    top: parent.bottom
                                    margins: 5 * pgst.scalef
                                }

                                text: modelData.newEpisodes
                            }
                        }
                    }
                }

                ButtonArea {
                    id: refresherButtonArea

                    anchors {
                        bottom: parent.bottom
                        right: parent.right
                    }

                    transparent: true
                    onClicked: py.call('main.check_for_episodes');
                    width: refresher.width + 2*refresher.anchors.margins
                    height: refresher.height + 2*refresher.anchors.margins

                    Image {
                        id: refresher
                        source: 'images/search.png'

                        anchors {
                            bottom: parent.bottom
                            right: parent.right
                            margins: 20 * pgst.scalef
                        }
                    }
                }
            }

            ButtonArea {
                onClicked: pgst.loadPage('PlayerPage.qml');

                anchors {
                    left: recommendationsPane.left
                    right: recommendationsPane.right
                }

                height: 100 * pgst.scalef

                PLabel {
                    anchors.centerIn: parent
                    text: 'Now playing'
                }
            }

            ButtonArea {
                onClicked: pgst.loadPage('Settings.qml');

                anchors {
                    left: recommendationsPane.left
                    right: recommendationsPane.right
                }

                height: 100 * pgst.scalef

                PLabel {
                    anchors.centerIn: parent
                    text: 'Settings'
                }
            }

            StartPageButton {
                id: recommendationsPane

                title: 'Recommendations'
                onClicked: pgst.loadPage('Settings.qml');

                Row {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                        margins: 40 * pgst.scalef
                    }

                    spacing: 20 * pgst.scalef

                    Connections {
                        target: pgst
                        onReadyChanged: {
                            if (pgst.ready) {
                                py.call('main.load_podcasts', [], function (podcasts) {
                                    recommendationsRepeater.model = podcasts.splice(0, 4);
                                });
                            }
                        }
                    }

                    Repeater {
                        id: recommendationsRepeater
                        Image { source: modelData.coverart; sourceSize { width: 80 * pgst.scalef; height: 80 * pgst.scalef } }
                    }
                }
            }
        }
    }
}

