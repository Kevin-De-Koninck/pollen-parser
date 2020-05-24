import os
import sys
import argparse
import yaml
from logzero import logger
from .app.app import Pollenparser


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-d", "--disable-push-notifications", action="store_true", default=False,
                        help="if true, no push notifications will be send to pushover")
    parser.add_argument("-f", "--config-file", action="store", default="POLLEN_PARSER_KEYS.yml",
                        help="YAML file containing the pushover keys")
    return parser.parse_args()


def validate_file(conf_file):
    if not os.path.exists(conf_file):
        logger.error("File '%s' does not exist...", conf_file)
        sys.exit(1)

    if not os.path.isfile(conf_file):
        logger.error("Path '%s' is not a file...", conf_file)
        sys.exit(1)


def parse_pushover_config_file(conf_file):
    results = {}
    with open(conf_file, 'r') as stream:
        try:
            results = yaml.safe_load(stream)
        except yaml.YAMLError as exc:
            logger.error("Error while parsing YAML file '%s':\n%s", conf_file, exc)
            sys.exit(1)

    if not results.get("pushover"):
        logger.error("File '%s' should contain a dictionary named 'pushover'...", conf_file)
        sys.exit(1)
    for key in ["API_token", "user_key"]:
        if not results.get("pushover").get(key):
            logger.error("File '%s' should contain a dictionary named 'pushover' with a key named '%s'...",
                         conf_file, key)
            sys.exit(1)

    return results


if __name__ == '__main__':
    args = parse_args()

    config_file = "/app/pollenparser/resources/{}".format(args.config_file)
    logger.debug("Using config file: %s", config_file)
    validate_file(config_file)
    pushover_config = parse_pushover_config_file(config_file)

    pollenparser = Pollenparser(disable_push_notifications=args.disable_push_notifications,
                                pushover_user_key=pushover_config.get("pushover").get("user_key"),
                                pushover_api_token=pushover_config.get("pushover").get("API_token"))
    pollenparser.parse_page_and_send_push_notification()
    sys.exit(0)

