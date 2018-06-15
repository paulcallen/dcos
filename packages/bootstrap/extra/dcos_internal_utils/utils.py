import logging

import portalocker

from pkgpanda.util import is_windows


log = logging.getLogger(__name__)


def read_file_line(filename):
    with open(filename, 'r') as f:
        return f.read().strip()


class Directory:
    def __init__(self, path):
        self.path = path
        if is_windows:
            # cannot lock a directory on windows so lets create a file instead
            self.path += "\\.directorylock"

    def __enter__(self):
        log.info('Opening {}'.format(self.path))
        self.fd = open(self.path, "w")
        log.info('Opened {} with fd {}'.format(self.path, self.fd))
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        log.info('Closing {} with fd {}'.format(self.path, self.fd))
        self.fd.close()

    def lock(self):
        return Flock(self.fd, portalocker.LOCK_EX)


class Flock:
    def __init__(self, fd, op):
        (self.fd, self.op) = (fd, op)

    def __enter__(self):
        log.info('Locking fd {}'.format(self.fd))
        # If the fcntl() fails, an IOError is raised.
        portalocker.lock(self.fd, self.op)
        log.info('Locked fd {}'.format(self.fd))
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        portalocker.unlock(self.fd)
        log.info('Unlocked fd {}'.format(self.fd))
