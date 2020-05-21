import logging
import pytest


LOGGER = logging.getLogger(__name__)


class TestPollenparser(object):
    TEST_HTML = '</div><h3 id="grassenstuifmeel">Grassenstuifmeel</h3><div class="meteo-store-pp"><table style="width: 500px"><tr><th>Datum</th><th>Risico op allergie</th></tr><tr><td style="width: 150px">21 mei 2020</td><td style="color: #FF0000">Zeer hoog</td></tr><tr><td style="width: 150px">22 mei 2020</td><td style="color: #FF0000">Zeer hoog</td></tr></table></div>'  # noqa: E501

    def test_get_page_success(self, pollenparser):
        # pylint: disable=W0612,W0613
        LOGGER.info("Testing method 'get_page'")
        page = pollenparser.get_page()
        assert page.content != ""
        assert page.status_code == 200

    def test_get_page_fail(self, capsys, pollenparser):
        # pylint: disable=W0612,W0613
        LOGGER.info("Testing method 'get_page' and expect it to fail")

        with pytest.raises(SystemExit) as pytest_wrapped_e:
            pollenparser.get_page(url="htp://fail.me")
        assert pytest_wrapped_e.type == SystemExit
        assert pytest_wrapped_e.value.code == -1

        with pytest.raises(SystemExit) as pytest_wrapped_e:
            pollenparser.get_page(url="http://google.com/lala")
        assert pytest_wrapped_e.type == SystemExit
        assert pytest_wrapped_e.value.code == 1

    def test_parse_page(self, pollenparser):
        # pylint: disable=W0612,W0613
        LOGGER.info("Testing method 'parse_page'")
        results = pollenparser.parse_page(self.TEST_HTML)
        assert results[0].get('Datum')
        assert results[0].get('Risico op allergie')

