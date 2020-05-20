import logging
from .context import Pollenparser


LOGGER = logging.getLogger(__name__)


def test_app(capsys, example_fixture):
    # pylint: disable=W0612,W0613
    LOGGER.info("Initializing Pollenparser class and running the method 'hello_world'")
    Pollenparser().hello_world()
    captured = capsys.readouterr()
    print("Captured output = {}".format(captured.out))
    assert "Hello World" in captured.out


def test_inc(example_fixture):
    # pylint: disable=W0612,W0613
    LOGGER.info("Initializing Pollenparser class and running the method 'inc'")
    b = Pollenparser()
    b.inc()
    assert b.value == 2

