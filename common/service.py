from gpodder.api import core
from concurrent.futures import ThreadPoolExecutor
import logging

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

gp_core = core.Core(progname="harbour-org.gpodder.sailfish")
with ThreadPoolExecutor() as executor:
    for p in gp_core.model.get_podcasts():
        executor.submit(lambda p: p.update(),p)

gp_core.shutdown()