import logging
from .context import Boilerplate


LOGGER = logging.getLogger(__name__)


def test_app(capsys, example_fixture):
    # pylint: disable=W0612,W0613
    LOGGER.info("Initializing Boilerplate class and running the method 'hello_world'")
    Boilerplate().hello_world()
    captured = capsys.readouterr()
    print("Captured output = {}".format(captured.out))
    assert "Hello World" in captured.out


def test_inc(example_fixture):
    # pylint: disable=W0612,W0613
    LOGGER.info("Initializing Boilerplate class and running the method 'inc'")
    b = Boilerplate()
    b.inc()
    assert b.value == 2

