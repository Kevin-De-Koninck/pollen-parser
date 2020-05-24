"""
Documentation

Some handy texts
"""

import argparse
from logzero import logger
from .app.app import Template


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("-p", "--port",
                        action="store", type=int,
                        help="Required positional argument")
    parser.add_argument("-f", "--flag",
                        action="store_true", default=False,
                        help="Optional argument flag which defaults to False")
    parser.add_argument("-n", "--name",
                        action="store",
                        help="Optional argument which requires a parameter (ei.g.: -n test)")
    parser.add_argument("-v", "--verbose",
                        action="count", default=0,
                        help="Optional verbosity counter (-v, -vv, etc)")

    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()
    logger.info("Argument -p|--port: %s", args.port)
    logger.info("Argument -f|--flag: %s", args.flag)
    logger.info("Argument -n|--name: %s", args.name)
    if args.verbose:
        logger.info("Argument -v|-vv|-vvv: %s", args.verbose)

    template = Template()
    template.inc()
    logger.debug("The value now is '%s'", template.value)

