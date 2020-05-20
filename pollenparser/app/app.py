"""
Documentation

Some handy texts
"""
from logzero import logger


class Pollenparser:
    def __init__(self):
        logger.debug("Initializing the value to 1")
        self.value = 1

    def inc(self):
        logger.debug("Incrementing the value")
        self.value += 1

    @staticmethod
    def hello_world():
        print("Hello World!")

