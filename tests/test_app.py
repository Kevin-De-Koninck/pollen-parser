import logging
<<<<<<< HEAD
=======
from .context import Template
>>>>>>> Initial commit


LOGGER = logging.getLogger(__name__)


<<<<<<< HEAD
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
=======
def test_app(capsys, example_fixture):
    # pylint: disable=W0612,W0613
    LOGGER.info("Initializing Template class and running the method 'hello_world'")
    Template().hello_world()
    captured = capsys.readouterr()
    print("Captured output = {}".format(captured.out))
    assert "Hello World" in captured.out


def test_inc(example_fixture):
    # pylint: disable=W0612,W0613
    LOGGER.info("Initializing Template class and running the method 'inc'")
    b = Template()
    b.inc()
    assert b.value == 2
>>>>>>> Initial commit

