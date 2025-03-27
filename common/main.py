#
# gPodder QML UI Reference Implementation
# Copyright (c) 2013, Thomas Perl <m@thp.io>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#

# Version of the QML UI implementation, this is usually the same as the version
# of gpodder-core, but we might have a different release schedule later on. If
# we decide to have parallel releases, we can at least start using this version
# to check if the core version is compatible with the QML UI version.
__version__ = '4.17.4'

import pyotherside
import gpodder
import podcastparser

from gpodder.api import core
from gpodder.api import util
from gpodder.api import query
from gpodder.api import registry
from gpodder import opml

import logging
import functools
import time
import datetime
import re
import os
from concurrent.futures import ThreadPoolExecutor

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

def run_in_background_thread(f):
    """Decorator for functions that take longer to finish

    The function will be run in its own thread, and control
    will be returned to the caller right away, which allows
    other Python code to run while this function finishes.

    The function cannot return a value (control is usually
    returned to the caller before execution is finished).
    """
    @functools.wraps(f)
    def wrapper(*args):
        util.run_in_background(lambda: f(*args))

    return wrapper


class gPotherSide:
    ALL_PODCASTS = -1

    def __init__(self):
        self.core = None
        self._checking_for_new_episodes = False

    def migrate_progname(self, progname):
        OLD_PROGNAME = 'harbour-org.gpodder.sailfish'

        pyotherside.send('loading-text', 'check-migration', False)

        home = os.path.expanduser('~')

        xdg_data_home = os.environ.get('XDG_DATA_HOME', os.path.join(home, '.local', 'share'))
        xdg_config_home = os.environ.get('XDG_CONFIG_HOME', os.path.join(home, '.config'))
        xdg_cache_home = os.environ.get('XDG_CACHE_HOME', os.path.join(home, '.cache'))

        old_paths = {}
        old_paths['data'] = os.path.join(xdg_data_home, OLD_PROGNAME)
        old_paths['config'] = os.path.join(xdg_config_home, OLD_PROGNAME)
        old_paths['cache'] = os.path.join(xdg_cache_home, OLD_PROGNAME)

        if OLD_PROGNAME == progname:
            pyotherside.send('loading-text', 'check-migration-dummy-run', True)

            for key, path in old_paths.items():
                pyotherside.send('loading-text', f'check-migration-{key}', False)
                if not os.path.isdir(path):
                    pyotherside.send('loading-text', 'migration-not-needed', False)
                    continue
                if os.path.isfile(f'{path}/.gpodder-migrate-ignore'):
                    pyotherside.send('loading-text', 'migration-ignore', False)
                    continue
                pyotherside.send('loading-text', 'migration-needed', False)

    def initialize(self, progname):
        assert self.core is None, 'Already initialized'

        self.migrate_progname(progname)

        pyotherside.send('loading-text', 'initializing-core', False)
        self.core = core.Core(progname=progname)
        pyotherside.send('loading-text', 'loading-podcasts', False)
        pyotherside.send('podcast-list-changed')

        self.core.config.add_observer(self._config_option_changed)

    def atexit(self):
        self.core.shutdown()

    def _config_option_changed(self, name, old_value, new_value):
        logger.warning('Config option changed: %s = %s -> %s', name, old_value, new_value)
        pyotherside.send('config-changed', name, new_value)

    def _get_episode_by_id(self, episode_id):
        for podcast in self.core.model.get_podcasts():
            for episode in podcast.episodes:
                if episode.id == episode_id:
                    return episode

    def _get_podcast_by_id(self, podcast_id):
        for podcast in self.core.model.get_podcasts():
            if podcast.id == podcast_id:
                return podcast

    def _episode_state_changed(self, episode):
        pyotherside.send('updated-episode', self.convert_episode(episode))
        pyotherside.send('updated-podcast', self.convert_podcast(episode.podcast))
        pyotherside.send('update-stats')

    def get_stats(self):
        podcasts = self.core.model.get_podcasts()

        total, deleted, new, downloaded, unplayed = 0, 0, 0, 0, 0
        for podcast in podcasts:
            to, de, ne, do, un = podcast.get_statistics()
            total += to
            deleted += de
            new += ne
            downloaded += do
            unplayed += un

        return {
            'podcasts': len(podcasts),
            'episodes': total,
            'newEpisodes': new,
            'downloaded': downloaded,
            'unplayed': unplayed,
        }

    def _get_cover(self, podcast):
        filename = self.core.cover_downloader.get_cover(podcast)
        if not filename:
            return ''
        return filename

    def _get_playback_progress(self, episode):
        if episode.total_time > 0 and episode.current_position > 0:
            return float(episode.current_position) / float(episode.total_time)

        return 0

    def convert_podcast(self, podcast):
        total, deleted, new, downloaded, unplayed = podcast.get_statistics()

        return {
            'id': podcast.id,
            'title': podcast.title,
            'description': podcast.one_line_description(),
            'newEpisodes': new,
            'downloaded': downloaded,
            'unplayed': unplayed,
            'coverart': self._get_cover(podcast),
            'updating': podcast._updating,
            'section': podcast.section,
            'url': podcast.url,
        }

    def _get_podcasts_sorted(self):
        sort_key = self.core.model.podcast_sort_key
        return sorted(self.core.model.get_podcasts(), key=lambda podcast: (podcast.section, sort_key(podcast)))

    def load_podcasts(self):
        podcasts = self._get_podcasts_sorted()
        return [self.convert_podcast(podcast) for podcast in podcasts]

    def _get_subtitle(self, episode):
        for line in util.remove_html_tags(episode.subtitle).strip().splitlines():
            return line
        return ''

    def convert_episode(self, episode):
        now = datetime.datetime.now()
        tnow = time.time()
        return {
            'id': episode.id,
            'title': episode.trimmed_title,
            'subtitle': self._get_subtitle(episode),
            'progress': episode.download_progress(),
            'downloadState': episode.state,
            'isNew': episode.is_new,
            'playbackProgress': self._get_playback_progress(episode),
            'published': util.format_date(episode.published),
            'section': self._format_published_section(now, tnow, episode.published),
            'hasShownotes': episode.description != '',
            'mime_type': episode.mime_type,
            'total_time': episode.total_time,
            'episode_art': self._get_episode_art(episode),
            'cover_art': self._get_cover(episode.podcast),
            'podcast_title': episode.podcast.title,
            'source': episode.local_filename(False) if episode.state == gpodder.STATE_DOWNLOADED else episode.url,
        }

    def _format_published_section(self, now, tnow, published):
        diff = (tnow - published)

        if diff < 60 * 60 * 24 * 7:
            return util.format_date(published)

        dt = datetime.datetime.fromtimestamp(published)
        if dt.year == now.year:
            return dt.strftime('%B %Y')

        return dt.strftime('%Y')

    def load_episodes(self, id=ALL_PODCASTS, eql=None):
        if id is not None and id != self.ALL_PODCASTS:
            podcasts = [self._get_podcast_by_id(id)]
        else:
            podcasts = self.core.model.get_podcasts()

        if eql:
            filter_func = query.EQL(eql).filter
        else:
            filter_func = lambda episodes: episodes

        result = []

        for podcast in podcasts:
            result.extend(filter_func(podcast.episodes))

        if id == self.ALL_PODCASTS:
            result.sort(key=lambda e: e.published, reverse=True)

        return [self.convert_episode(episode) for episode in result]

    def get_fresh_episodes_summary(self, count):
        summary = []
        for podcast in self.core.model.get_podcasts():
            _, _, new, _, _ = podcast.get_statistics()
            if new:
                summary.append({
                    'title': podcast.title,
                    'coverart': self._get_cover(podcast),
                    'newEpisodes': new,
                })

        summary.sort(key=lambda e: e['newEpisodes'], reverse=True)
        return summary[:int(count)]

    @run_in_background_thread
    def import_opml(self, url):
        """Import subscriptions from an OPML file

        import http://example.com/subscriptions.opml

            Import subscriptions from the given URL

        import ./feeds.opml

            Import subscriptions from a local file
        """
        for channel in opml.Importer(url).items:
            self.subscribe(channel['url'], channel['section'])

    @run_in_background_thread
    def export_opml(self, uri):
        """ Export subscriptions to an OPML file

        URI can be either just a name or a full path as long as writing to said path is possible.
        """
        opml.Exporter(uri).write(self.core.model.get_podcasts())

    @run_in_background_thread
    def subscribe(self, url, section = None):
        url = self.core.model.normalize_feed_url(url)
        # TODO: Check if subscription already exists

        # Kludge: After one second, update the podcast list,
        # so that we see the podcast that is being updated
        @run_in_background_thread
        def show_loading():
            time.sleep(1)
            pyotherside.send('podcast-list-changed')
        show_loading()

        try:
            podcast = self.core.model.load_podcast(url, create=True)
        except Exception as e:
            pyotherside.send('core-error', 'Feed URL: {}\nload_podcast error: {}'.format(url, str(e)))
            pyotherside.send('podcast-list-changed')
            return false

        if section is not None:
            podcast.section = section

        self.core.save()
        pyotherside.send('podcast-list-changed')
        pyotherside.send('update-stats')
        # TODO: Return True/False for reporting success

    def rename_podcast(self, podcast_id, new_title):
        podcast = self._get_podcast_by_id(podcast_id)
        podcast.rename(new_title)
        self.core.save()
        pyotherside.send('podcast-list-changed')

    def change_section(self, podcast_id, new_section):
        podcast = self._get_podcast_by_id(podcast_id)
        podcast.section = new_section
        podcast.save()
        self.core.save()
        pyotherside.send('podcast-list-changed')

    def unsubscribe(self, podcast_id):
        podcast = self._get_podcast_by_id(podcast_id)
        podcast.unsubscribe()
        self.core.save()
        pyotherside.send('podcast-list-changed')
        pyotherside.send('update-stats')

    @run_in_background_thread
    def download_episode(self, episode_id):
        episode = self._get_episode_by_id(episode_id)
        if episode.state == gpodder.STATE_DOWNLOADED:
            return

        def progress_callback(progress):
            self._episode_state_changed(episode)

        # TODO: Handle the case where there is already a DownloadTask
        episode.download(progress_callback)
        self.core.save()
        self.core.cover_downloader.get_cover(self._get_podcast_by_id(episode.podcast_id), download=True, episode=episode)
        self._episode_state_changed(episode)

    def delete_episode(self, episode_id):
        episode = self._get_episode_by_id(episode_id)
        episode.delete_download()
        self.core.save()
        self._episode_state_changed(episode)

    def toggle_new(self, episode_id):
        episode = self._get_episode_by_id(episode_id)
        episode.is_new = not episode.is_new
        if episode.is_new and episode.state == gpodder.STATE_DELETED:
            episode.state = gpodder.STATE_NORMAL
        episode.save()
        self.core.save()
        self._episode_state_changed(episode)

    def mark_episodes_as_old(self, podcast_id):
        podcast = self._get_podcast_by_id(podcast_id)

        any_changed = False
        for episode in podcast.episodes:
            if episode.is_new and episode.state == gpodder.STATE_NORMAL:
                any_changed = True
                episode.is_new = False
                episode.save()

        if any_changed:
            pyotherside.send('episode-list-changed', podcast_id)
            pyotherside.send('updated-podcast', self.convert_podcast(podcast))
            pyotherside.send('update-stats')

        self.core.save()

    def save_playback_state(self):
        self.core.save()

    @run_in_background_thread
    def check_for_episodes(self, url=None):
        if self._checking_for_new_episodes:
            return
        self._checking_for_new_episodes = True
        pyotherside.send('refreshing', True)
        podcasts = [podcast for podcast in self._get_podcasts_sorted() if url is None or podcast.url == url]
        logger.info("updating %d podcasts", len(podcasts))
        with ThreadPoolExecutor() as executor:
            for idx, p in enumerate(podcasts):
                executor.submit(self._update_single_podcast, idx, p, len(podcasts))
        logger.info("finished updating podcasts")
        self.core.save()
        self._checking_for_new_episodes = False
        pyotherside.send('refreshing', False)

    def _update_single_podcast(self, index, podcast, num_podcasts):
        try:
            pyotherside.send('refresh-progress', index, num_podcasts)
            pyotherside.send('updating-podcast', podcast.id)
            try:
                podcast.update()
            except Exception as e:
                logger.warning('Could not update %s: %s', 'podcast.url', str(e))
                pyotherside.send('core-error', 'Could not update: {}\nFeed URL: {}\nError: {}'.format(podcast.title, podcast.url, str(e)))
            pyotherside.send('updated-podcast', self.convert_podcast(podcast))
            pyotherside.send('update-stats')
        except Exception as e:
            logger.warning('Error in update task', e, exc_info=True)

    def _get_episode_art(self, episode):
        filename = self.core.cover_downloader.get_cover(episode.podcast, False, episode)
        if not filename:
            return ''
        return filename

    def play_episode(self, episode_id):
        episode = self._get_episode_by_id(episode_id)
        episode.playback_mark()
        self.core.save()
        self._episode_state_changed(episode)
        return {
            'title': episode.title,
            'podcast_title': episode.podcast.title,
            'cover_art': self._get_cover(episode.podcast),
            'episode_art': self._get_episode_art(episode),
            'source': episode.local_filename(False) if episode.state == gpodder.STATE_DOWNLOADED else episode.url,
            'position': episode.current_position,
            'total': episode.total_time,
            'video': episode.file_type() == 'video',
            'chapters': getattr(episode, 'chapters', []),
            'description': episode.description_html or episode.description,
            'metadata': ' | '.join(self._format_metadata(episode)),
            'link': episode.link if episode.link != episode.url else '',
        }

    def report_playback_event(self, episode_id, position_from, position_to, duration):
        episode = self._get_episode_by_id(episode_id)
        print('Played', episode.title, 'from', position_from, 'to', position_to, 'of', duration)
        episode.report_playback_event(position_from, position_to, duration)
        pyotherside.send('playback-progress', episode_id, self._get_playback_progress(episode))

    def show_episode(self, episode_id):
        episode = self._get_episode_by_id(episode_id)
        if episode is None:
            return {}

        return {
            'title': episode.trimmed_title,
            'description': episode.description_html or episode.description,
            'metadata': ' | '.join(self._format_metadata(episode)),
            'link': episode.link if episode.link != episode.url else '',
            'chapters': getattr(episode, 'chapters', []),
        }

    def _format_metadata(self, episode):
        if episode.published:
            yield datetime.datetime.fromtimestamp(episode.published).strftime('%Y-%m-%d')

        if episode.file_size > 0:
            yield '%.2f MiB' % (episode.file_size / (1024 * 1024))

        if episode.total_time > 0:
            yield '%02d:%02d:%02d' % (episode.total_time / (60 * 60),
                                      (episode.total_time / 60) % 60,
                                      episode.total_time % 60)

    def show_podcast(self, podcast_id):
        podcast = self._get_podcast_by_id(podcast_id)
        if podcast is None:
            return {}

        return {
            'title': podcast.title,
            'description': util.remove_html_tags(podcast.description),
            'link': podcast.link,
            'url': podcast.url,
            'section': podcast.section,
            'coverart': self._get_cover(podcast),
        }

    def set_config_value(self, option, value):
        self.core.config.update_field(option, value)

    def get_config_value(self, option):
        return self.core.config.get_field(option)

    def get_path_media_status(self, path):
        """
        Returns whether a .nomedia file exists in the provided path (usually the new downloads_path)
        .nomedia on SFOS signifies to the tracker not to scan the folder.
        """
        nomedia_path = '{}/.nomedia'.format(path)
        nomedia_exists = os.path.isfile(nomedia_path)
        logger.debug('path {} - {}'.format(nomedia_path, nomedia_exists))
        return nomedia_exists

    def toggle_path_nomedia(self, path, status):
        """
        Adds/removes the .nomedia file from the downloads path.
        """
        nomedia_path = '{}/.nomedia'.format(path)
        if status:
            logger.debug('Create nomedia file at {}'.format(nomedia_path))
            open(nomedia_path, 'w')

        else:
            logger.debug('Remove nomedia file at {}'.format(nomedia_path))
            os.remove(nomedia_path)


    def get_directory_providers(self):
        def select_provider(p):
            return p.kind in (p.PROVIDER_SEARCH, p.PROVIDER_STATIC)

        def provider_sort_key(p):
            return p.priority

        return [{
            'label': provider.name,
            'can_search': provider.kind == provider.PROVIDER_SEARCH
        } for provider in sorted(registry.directory.select(select_provider), key=provider_sort_key, reverse=True)]

    def get_directory_entries(self, provider, query):
        def match_provider(p):
            return p.name == provider

        for provider in registry.directory.select(match_provider):
            try:
                return [{
                    'title': e.title,
                    'url': e.url,
                    'image': e.image,
                    'subscribers': e.subscribers,
                    'description': e.description,
                } for e in provider.on_string(query)]
            except Exception as e:
                pyotherside.send('core-error', format(str(e)))

        return []


PILL_TEMPLATE = """<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" height="{height}" width="{width}"
    xmlns:xlink="http://www.w3.org/1999/xlink">
  <defs>
    <linearGradient x1="0" y1="0" x2="1" y2="1" id="rightGradient">
      <stop offset="0.0" style="stop-color: #333333; stop-opacity: 0.9;" />
      <stop offset="0.4" style="stop-color: #333333; stop-opacity: 0.8;" />
      <stop offset="0.6" style="stop-color: #333333; stop-opacity: 0.6;" />
      <stop offset="0.9" style="stop-color: #333333; stop-opacity: 0.7;" />
      <stop offset="1.0" style="stop-color: #333333; stop-opacity: 0.5;" />
    </linearGradient>

    <linearGradient x1="0" y1="0" x2="1" y2="1" id="leftGradient">
      <stop offset="0.0" style="stop-color: #cccccc; stop-opacity: 0.5;" />
      <stop offset="0.4" style="stop-color: #cccccc; stop-opacity: 0.7;" />
      <stop offset="0.6" style="stop-color: #cccccc; stop-opacity: 0.6;" />
      <stop offset="0.9" style="stop-color: #cccccc; stop-opacity: 0.8;" />
      <stop offset="1.0" style="stop-color: #cccccc; stop-opacity: 0.9;" />
    </linearGradient>

    <path id="rightPath" d="M {width/2} 0 l {width/2-radius-1} 0
             s {radius} 0 {radius} {radius} l 0 {height-radius*2}
             s 0 {radius} {-radius} {radius} l {-(width/2-radius-1)} 0 z" />
    <path id="rightPathOuter" d="M {width/2+0.5} {0.5} l {width/2-radius-2} 0
             s {radius} 0 {radius} {radius} l 0 {height-radius*2-1}
             s 0 {radius} {-radius} {radius} l {-(width/2-radius-2)} 0 z" />
    <path id="rightPathInner" d="M {width/2+1.5} {1.5} l {width/2-radius-4} 0
             s {radius} 0 {radius} {radius} l 0 {height-radius*2-3}
             s 0 {radius} {-radius} {radius} l {-(width/2-radius-4)} 0 z" />

    <path id="leftPath" d="M {width/2} 0 l {-(width/2-radius-1)} 0
             s {-radius} 0 {-radius} {radius} l 0 {height-radius*2}
             s 0 {radius} {radius} {radius} l {width/2-radius-1} 0 z" />
    <path id="leftPathOuter" d="M {width/2-0.5} {0.5} l {-(width/2-radius-2)} 0
             s {-radius} 0 {-radius} {radius} l 0 {height-radius*2-1}
             s 0 {radius} {radius} {radius} l {width/2-radius-2} 0 z" />
    <path id="leftPathInner" d="M {width/2-1.5} {1.5} l {-(width/2-radius-4)} 0
             s {-radius} 0 {-radius} {radius} l 0 {height-radius*2-3}
             s 0 {radius} {radius} {radius} l {width/2-radius-4} 0 z" />
  </defs>

  <g style="font-family: sans-serif; font-size: {font_size}px; font-weight: bold;">
      <g style="display: {'inline' if left_text else 'none'};">
          <use xlink:href="#leftPath" style="fill:url(#leftGradient);"/>
          <use xlink:href="#leftPathOuter" style="{outer_style}" />
          <use xlink:href="#leftPathInner" style="{inner_style}" />
          <text x="{lx+1}" y="{height/2+font_size/3+1}" fill="black">{left_text}</text>
          <text x="{lx}" y="{height/2+font_size/3}" fill="white">{left_text}</text>
      </g>

      <g style="display: {'inline' if right_text else 'none'};">
          <use xlink:href="#rightPath" style="fill:url(#rightGradient);"/>
          <use xlink:href="#rightPathOuter" style="{outer_style}" />
          <use xlink:href="#rightPathInner" style="{inner_style}" />
          <text x="{rx+1}" y="{height/2+font_size/3+1}" fill="black">{right_text}</text>
          <text x="{rx}" y="{height/2+font_size/3}" fill="white">{right_text}</text>
      </g>
  </g>
</svg>
"""


class PillExpression(object):
    def __init__(self, **kwargs):
        self.kwargs = kwargs

    def __call__(self, matchobj):
        return str(eval(matchobj.group(1), self.kwargs))


def pill_image_provider(image_id, requested_size):
    left_text, right_text = (int(x) for x in image_id.split('/'))

    width = 44
    height = 24
    radius = 6
    font_size = 13

    text_lx = width / 4
    text_rx = width * 3 / 4

    charwidth = font_size / 1.3

    if left_text:
        text_lx -= charwidth * len(str(left_text)) / 2
    if right_text:
        text_rx -= charwidth * len(str(right_text)) / 2

    outer_style = 'stroke: #333333; stroke-width: 1; fill-opacity: 0; stroke-opacity: 0.6;'
    inner_style = 'stroke: #ffffff; stroke-width: 1; fill-opacity: 0; stroke-opacity: 0.3;'

    expression = PillExpression(height=height, width=width, left_text=left_text,
                                right_text=right_text, radius=radius,
                                lx=text_lx, rx=text_rx, font_size=font_size,
                                outer_style=outer_style, inner_style=inner_style)
    svg = re.sub(r'[{]([^}]+)[}]', expression, PILL_TEMPLATE)
    return bytearray(svg.encode('utf-8')), (width, height), pyotherside.format_data


@pyotherside.set_image_provider
def gpotherside_image_provider(image_id, requested_size):
    provider, args = image_id.split('/', 1)
    if provider == 'pill':
        return pill_image_provider(args, requested_size)

    raise ValueError('Unknown provider: %s' % (provider,))


gpotherside = gPotherSide()
pyotherside.atexit(gpotherside.atexit)

pyotherside.send('hello', gpodder.__version__, __version__, podcastparser.__version__)

# Exposed API Endpoints for calls from QML
initialize = gpotherside.initialize
load_podcasts = gpotherside.load_podcasts
load_episodes = gpotherside.load_episodes
show_episode = gpotherside.show_episode
play_episode = gpotherside.play_episode
import_opml = gpotherside.import_opml
export_opml = gpotherside.export_opml
subscribe = gpotherside.subscribe
unsubscribe = gpotherside.unsubscribe
check_for_episodes = gpotherside.check_for_episodes
get_stats = gpotherside.get_stats
get_fresh_episodes_summary = gpotherside.get_fresh_episodes_summary
download_episode = gpotherside.download_episode
delete_episode = gpotherside.delete_episode
toggle_new = gpotherside.toggle_new
rename_podcast = gpotherside.rename_podcast
change_section = gpotherside.change_section
report_playback_event = gpotherside.report_playback_event
mark_episodes_as_old = gpotherside.mark_episodes_as_old
save_playback_state = gpotherside.save_playback_state
set_config_value = gpotherside.set_config_value
get_config_value = gpotherside.get_config_value
get_path_media_status = gpotherside.get_path_media_status
toggle_path_nomedia = gpotherside.toggle_path_nomedia
get_directory_providers = gpotherside.get_directory_providers
get_directory_entries = gpotherside.get_directory_entries
show_podcast = gpotherside.show_podcast
