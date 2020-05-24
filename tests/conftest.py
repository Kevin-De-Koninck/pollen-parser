import logging
import pytest
from .context import Template


LOGGER = logging.getLogger(__name__)


@pytest.fixture(scope='function')
def template_object():
    LOGGER.info("Initializing the module and returning the object...")
    yield Template()
    LOGGER.info("Breaking down the module.")
    # Do clean up here

