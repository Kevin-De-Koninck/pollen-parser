import logging
import pytest
from .context import Pollenparser


LOGGER = logging.getLogger(__name__)


@pytest.fixture(scope='function')
def pollenparser():
    LOGGER.info("Initializing the Pollenparser class with disabled push notifications...")
    yield Pollenparser(disable_push_notifications=False)
    LOGGER.info("Tearing down the Pollenparser instance with disabled push notifications...")

