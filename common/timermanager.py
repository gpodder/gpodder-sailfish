import pathlib
import logging
import os
import subprocess

logger = logging.getLogger(__name__)


class TimerManager():
    def __init__(self, unit_name="harbour-org.gpodder.sailfish",
                 unit_file_location="/home/defaultuser/.config/systemd/user/"):
        self.unit_name = unit_name
        self.prefix = unit_file_location
        self.prefixpath = pathlib.Path(self.prefix)
        if not self.prefixpath.exists():
            raise NotADirectoryError("folder '%s' for local unit files does not exist!" % self.prefixpath.absolute())
        self.timerfile = self.prefixpath.joinpath('%s.timer' % self.unit_name)
        self.servicefile = self.prefixpath.joinpath('%s.service' % self.unit_name)

    def timer_and_service_exist(self):
        logger.debug(
            "searching for systemd unit files: '%s' '%s'" % (self.timerfile.absolute(), self.servicefile.absolute()))
        return self.timerfile.is_file() and self.servicefile.is_file()

    def write_service(self):
        self.remove_file(self.servicefile)
        with open(self.servicefile, "w") as file:
            file.write("""
[Unit]
Description=%s service
[Service]
ExecStart=/usr/share/harbour-org.gpodder.sailfish/service.py 
            """ % self.unit_name)

    def write_timer(self, interval="*-*-* *:*:0"):
        self.remove_file(self.timerfile)
        with open(self.timerfile, "w") as file:
            file.write("""
[Unit]
Description=Timer for %s

[Timer]
OnCalendar=%s
Persistent=true

[Install]
WantedBy=timers.target
            """ % (self.unit_name, interval))

    def remove_file(self, file):
        if file.is_file():
            logger.debug("servicefile existed, will overwrite!")
            os.remove(file.absolute())

    def activate_timer(self):
        subprocess.run(["systemctl", "--user", "enable", "%s.timer" % self.unit_name])
        subprocess.run(["systemctl", "--user", "restart", "%s.timer" % self.unit_name])

    def deactivate_timer(self):
        subprocess.run(["systemctl", "--user", "stop", "%s.timer" % self.unit_name])
        subprocess.run(["systemctl", "--user", "disable", "%s.timer" % self.unit_name])
