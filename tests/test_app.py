import logging


LOGGER = logging.getLogger(__name__)


def test_app(capsys, template_object):
    # pylint: disable=W0612,W0613
    LOGGER.info("Running the method 'hello_world' and checking the output on stdout.")
    template_object.hello_world()
    captured = capsys.readouterr()
    assert "Hello World" in captured.out


def test_inc(template_object):
    # pylint: disable=W0612,W0613
    LOGGER.info("Initializing Template class and running the method 'inc'")
    template_object.inc()
    assert template_object.value == 2

