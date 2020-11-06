from gpodder.api import core
from concurrent.futures import ThreadPoolExecutor
import logging
import dbus
import gettext

appname = "harbour-org.gpodder.sailfish"
lang_translations = gettext.translation('base',
                                        localedir='/usr/share/harbour-org.gpodder.sailfish/translations/py_gettext')
_ = lang_translations.gettext

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

logger.info("starting scheduled gpodder refresh")


def run_update():
    gp_core = core.Core(progname=appname)
    with ThreadPoolExecutor() as executor:
        for p in gp_core.model.get_podcasts():
            executor.submit(lambda p: p.update(), p)

    gp_core.shutdown()

run_update()


bus = dbus.SessionBus(private=False)
notify = dbus.Interface(bus.get_object("org.freedesktop.Notifications", "/org/freedesktop/Notifications"),
                        'org.freedesktop.Notifications')
notify.Notify(appname, 200, "icon-s-filled-warning", _('gpodder.refresh_notification_title'),
              _('gpodder.refresh_notification_body'),
              ["", "default", "", "app"],
              {'x-nemo-preview-summary': _('gpodder.refresh_notification_title'),
               'x-nemo-preview-body': _('gpodder.refresh_notification_body')}, -1)
