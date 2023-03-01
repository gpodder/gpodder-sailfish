
import QtQuick 2.0
import QtMultimedia 5.0
import Amber.Mpris 1.0

MprisPlayer {

    id: mprisPlayer

    serviceName: "gpodder"

    property string artist
    property string song
    property string cover

    onArtistChanged: mprisPlayer.metaData.contributingArtist = artist

    onSongChanged: mprisPlayer.metaData.title = song

    onCoverChanged: mprisPlayer.metaData.artUrl = cover

    // Mpris2 Root Interface
    identity: "gPodder"

    // Mpris2 Player Interface
    canControl: true

    canGoNext: player.playbackState !== MediaPlayer.StoppedState
    canGoPrevious: player.playbackState !== MediaPlayer.StoppedState
    canPause: player.playbackState !== MediaPlayer.StoppedState
    canPlay: player.playbackState !== MediaPlayer.StoppedState
    canSeek: false

    loopStatus: Mpris.LoopNone
    shuffle: false
    volume: 1

    playbackStatus: {
        if (player.playbackState === MediaPlayer.PlayingState) return Mpris.Playing
        else if (player.playbackState === MediaPlayer.PausedState) return Mpris.Paused
        else return Mpris.Stopped
    }

    onPlaybackStatusChanged: {
        song = player.episode_title
        artist = player.podcast_title
        if (player.episode_art != '') {
            cover = player.episode_art
        } else {
            cover = player.cover_art
        }
    }

    onPauseRequested: {
        player.pause()
    }
    onPlayRequested: {
        player.play()
    }
    onPlayPauseRequested: {
        player.togglePause()
    }
    onStopRequested: {
        player.stop()
    }
    
    onNextRequested: {
        player.seekAndSync(player.position + 1000 * 10)
    }
    onPreviousRequested: {
        player.seekAndSync(player.position - 1000 * 10)
    }
    
}
