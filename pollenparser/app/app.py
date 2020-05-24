import sys
import requests
from bs4 import BeautifulSoup
from logzero import logger
from .pushover import Pushover


class Pollenparser:
    SOURCE_PAGE = "https://www.meteo.be/nl/weer/verwachtingen/stuifmeelallergie-en-hooikoorts"

    def __init__(self, disable_push_notifications=False, pushover_user_key=None, pushover_api_token=None):
        self.column1_header = "column_1"
        self.column2_header = "column_2"
        self.disable_push_notifications = disable_push_notifications
        if pushover_user_key is not None and pushover_api_token is not None:
            self.pushover = Pushover(pushover_user_key, pushover_api_token)
        else:
            self.pushover = None

    def parse_page_and_send_push_notification(self):
        page = self.get_page()
        results = self.parse_page(page.content)
        if not self.disable_push_notifications:
            self.send_push_notification(results)

    def get_page(self, url=None):
        page = None
        if url is None:
            url = self.SOURCE_PAGE
        try:
            page = requests.get(url)
            if page.status_code != 200:
                logger.error("Unable to retrieve page (returncode != 200):\n%s", url)
                sys.exit(1)
        except requests.exceptions.InvalidSchema as e:
            logger.error("Unable to retrieve page:\n%s", url)
            logger.exception(e)
            sys.exit(-1)
        return page

    def parse_page(self, html):
        soup = BeautifulSoup(html, 'html.parser')
        header_above_table = soup.find("h3", id="grassenstuifmeel")
        table = header_above_table.find_next("table")
        results = []
        for row in table.findAll('tr'):
            item = {}
            if row.findAll("th"):
                self.column1_header = row.findAll("th")[0].string
                self.column2_header = row.findAll("th")[1].string
                continue
            else:
                item[self.column1_header] = row.findAll("td")[0].string
                item[self.column2_header] = row.findAll("td")[1].string
            results.append(item)
        logger.debug("The following results were retrieved:\n%s", repr(results))
        return results

    def send_push_notification(self, results):
        message = ""
        for result in results:
            if message != "":
                message = "{}\n".format(message)
            message = "{}{}\t{}".format(message, result.get(self.column1_header), result.get(self.column2_header))
        self.pushover.send_notification(message)

