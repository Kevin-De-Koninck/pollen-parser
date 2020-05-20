import logging
import pytest
<<<<<<< HEAD
from .context import Template

=======
>>>>>>> Initial commit

LOGGER = logging.getLogger(__name__)


@pytest.fixture(scope='function')
<<<<<<< HEAD
def template_object():
    LOGGER.info("Initializing the module and returning the object...")
    yield Template()
    LOGGER.info("Breaking down the module.")
    # Do clean up here
=======
def example_fixture():
    LOGGER.info("Setting Up Example Fixture...")
    yield
    LOGGER.info("Tearing Down Example Fixture...")
>>>>>>> Initial commit

