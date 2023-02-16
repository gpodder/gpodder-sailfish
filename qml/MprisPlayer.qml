
import QtQuick 2.0
import QtMultimedia 5.0
import org.nemomobile.mpris 1.0

MprisPlayer {

    id: mprisPlayer

    serviceName: "gpodder"

    property string artist
    property string song

    onArtistChanged: {
        var metadata = mprisPlayer.metadata
        metadata[Mpris.metadataToString(Mpris.Artist)] = artist // Podcast Title
        mprisPlayer.metadata = metadata
    }

    onSongChanged: {
        var metadata = mprisPlayer.metadata
        metadata[Mpris.metadataToString(Mpris.Title)] = song // Episode Title
        mprisPlayer.metadata = metadata
    }


    // Mpris2 Root Interface
    identity: "gPodder"

    // Mpris2 Player Interface
    canControl: true

    canGoNext: player.playbackState !== MediaPlayer.StoppedState
    canGoPrevious: player.playbackState !== MediaPlayer.StoppedState
    canPause: player.playbackState !== MediaPlayer.StoppedState
    canPlay: player.playbackState !== MediaPlayer.StoppedState
    canSeek: false

    loopStatus: Mpris.None
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
