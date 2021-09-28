
/**
 *
 * gPodder QML UI Reference Implementation
 * Copyright (c) 2013, 2014, Thomas Perl <m@thp.io>
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
import QtMultimedia 5.0

MediaPlayer {
    id: player

    property int episode: 0
    property string episode_title: ''
    property var episode_chapters: ([])
    property string podcast_title: ''
    property string cover_art: ''
    property string episode_art: ''
    signal playerCreated()

    property var queue: ([])
    signal queueUpdated()
    property bool isPlaying: playbackState == MediaPlayer.PlayingState
    property bool isPaused: playbackState == MediaPlayer.PausedState
    property bool isStopped: playbackState == MediaPlayer.StoppedState

    property bool inhibitPositionEvents: false
    property bool seekAfterPlay: false
    property int seekTargetSeconds: 0
    property int lastPosition: 0
    property int lastDuration: 0
    property int playedFrom: 0

    property var androidConnections: Connections {
        target: platform.android ? gpodderAndroid : null

        onAudioBecomingNoisy: {
            if (playbackState === MediaPlayer.PlayingState) {
                pause();
            }
        }
    }

    function togglePause() {
        if (playbackState === MediaPlayer.PlayingState) {
            pause();
        } else if (playbackState === MediaPlayer.PausedState) {
            play();
        }
    }

    function enqueueEpisode(episode_id, callback) {
        py.call('main.show_episode', [episode_id], function (episode) {
            if (episode_id !== player.episode && !queue.some(function (queued) {
                return queued.episode_id === episode_id;
            })) {
                queue.push({
                    episode_id: episode_id,
                    title: episode.title,
                });
                queueUpdated();
            }

            if (callback !== undefined) {
                callback();
            }
        });
    }

    function clearQueue() {
        while (queue.length) {
            queue.shift()
        }
        queueUpdated()
    }

    function playbackEpisode(episode_id) {
        if (episode === episode_id) {
            // If the episode is already loaded, just start playing
            play();
            return;
        }

        // First, make sure we stop any seeking / position update events
        sendPositionToCore(lastPosition);
        player.inhibitPositionEvents = true;
        player.stop();

        py.call('main.play_episode', [episode_id], function (episode) {
            if (episode.video) {
                player.inhibitPositionEvents = false;
                Qt.openUrlExternally(episode.source);
                return;
            }

            // Load media / prepare and start playback
            var old_episode = player.episode;
            player.episode = episode_id;
            player.episode_title = episode.title;
            player.episode_chapters = episode.chapters;
            player.podcast_title = episode.podcast_title;
            player.cover_art = episode.cover_art;
            player.episode_art = episode.episode_art;
            var source = episode.source;
            if (source.indexOf('/') === 0) {
                player.source = 'file://' + source;
            } else {
                player.source = source;
            }
            player.seekTargetSeconds = episode.position;
            seekAfterPlay = true;

            // Notify interested parties that the player is now active
            if (old_episode === 0) {
                player.playerCreated();
            }

            player.play();
        });
    }

    function seekAndSync(target_position) {
        sendPositionToCore(lastPosition);
        seek(target_position);
        playedFrom = target_position;
        savePlaybackAfterStopTimer.restart();
    }

    onPlaybackStateChanged: {
        if (playbackState == MediaPlayer.PlayingState) {
            if (!seekAfterPlay) {
                player.playedFrom = position;
            }
        } else {
            sendPositionToCore(lastPosition);
            savePlaybackAfterStopTimer.restart();
        }
    }

    function flushToDisk() {
        py.call('main.save_playback_state', []);
    }

    property var durationChoices: ([5, 15, 30, 45, 60])

    function startSleepTimer(seconds) {
        sleepTimer.running = false;
        sleepTimer.secondsRemaining = seconds;
        sleepTimer.running = true;
    }

    function stopSleepTimer() {
        sleepTimer.running = false;
        sleepTimer.secondsRemaining = 0;
    }

    property bool sleepTimerRunning: sleepTimer.running
    property int sleepTimerRemaining: sleepTimer.secondsRemaining

    property var sleepTimer: Timer {
        property int secondsRemaining: 0

        interval: 1000
        repeat: true
        onTriggered: {
            secondsRemaining -= 1;

            if (secondsRemaining <= 0) {
                player.pause();
                running = false;
            }
        }
    }

    property var nextInQueueTimer: Timer {
        interval: 500

        repeat: false

        onTriggered: {
            if (queue.length > 0) {
                playbackEpisode(queue.shift().episode_id);
                player.queueUpdated();
            }
        }
    }

    function jumpToQueueIndex(index) {
        playbackEpisode(removeQueueIndex(index).episode_id);
    }

    function removeQueueIndex(index) {
        var result = queue.splice(index, 1)[0];
        player.queueUpdated();
        return result;
    }

    onStatusChanged: {
        if (status === MediaPlayer.EndOfMedia) {
            nextInQueueTimer.start();
        }
    }

    property var savePlaybackPositionTimer: Timer {
        // Save position every minute during playback
        interval: 60 * 1000
        repeat: true
        running: player.isPlaying
        onTriggered: player.flushToDisk();
    }

    property var savePlaybackAfterStopTimer: Timer {
        // Save position shortly after every seek and pause event
        interval: 5 * 1000
        repeat: false
        onTriggered: player.flushToDisk();
    }

    property var seekAfterPlayTimer: Timer {
        interval: 100
        repeat: true
        running: player.isPlaying && player.seekAfterPlay

        onTriggered: {
            var targetPosition = player.seekTargetSeconds * 1000;
            if (Math.abs(player.position - targetPosition) < 10 * interval) {
                // We have seeked properly
                player.inhibitPositionEvents = false;
                player.seekAfterPlay = false;
            } else {
                // Try to seek to the target position
                player.seek(targetPosition);
                player.playedFrom = targetPosition;
            }
        }
    }

    function sendPositionToCore(positionToSend) {
        if (episode != 0 && !inhibitPositionEvents) {
            var begin = playedFrom / 1000;
            var end = positionToSend / 1000;
            var duration = ((lastDuration > 0) ? lastDuration : 0) / 1000;
            var diff = end - begin;

            // Only send playback events if they are 2 seconds or longer
            // (all other events might just be seeking events or wrong ones)
            if (diff >= 2) {
                py.call('main.report_playback_event', [episode, begin, end, duration]);
            }
        }
    }

    onPositionChanged: {
        if (isPlaying && !inhibitPositionEvents) {
            lastPosition = position;
            lastDuration = duration;

            // Directly update the playback progress in the episode list
            py.playbackProgress(episode, position / duration);
        }
    }

    onPlaybackRateChanged: {
        if(isPlaying) {
            seekAndSync(position - 0.01);
        }
    }
}
