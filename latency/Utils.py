#!/usr/bin/python2.7

import subprocess
import time
import logging
import os
import sys
import shutil
import signal
import resource

logger = logging.getLogger('Benchmark.Utils')

def unixTime():
    """ Return current unix time """

    return time.time()

def setlimits():
    """ Set maximum number of open file to 4096 to child process """
    #print "Setting resource limit in child (pid %d)" % os.getpid()
    resource.setrlimit(resource.RLIMIT_NOFILE, (4096, 4096))

def process_exec(cmd, log, verbose=True):
    """ Run the command with Popen() and wait until the process finishes. Also, forward output to file """

    if verbose:
        logger.critical("$ %s", cmd)

    with open(log, "w") as f:
        try:
            #r = subprocess.check_output("%s 2>&1 > %s" % (cmd, log), stderr=subprocess.STDOUT, shell=True)
            #os.system("/bin/bash -c \"%s\" 2>&1 > %s" % (cmd, log))
            p = subprocess.Popen(cmd, shell=True, universal_newlines=True, stdout=f, stderr=f, preexec_fn=setlimits)
            p.wait()
            f.flush()
            #p = subprocess.Popen("%s 2>&1 > %s" % (cmd, log), shell=True, universal_newlines=True, stdout=log, stderr=log)
            r = ""
        except subprocess.CalledProcessError, e:
            r = str(e.output)

    with open(log, "a") as f:
        f.write("return code = %d\n" % p.returncode)
        f.flush()

    if verbose:
        logger.info("%s", r)
    return r

def shell_launch(cmd, verbose=True):
    """ Run the command with fork() and immediately returns. """

    if verbose:
        logger.critical("$ %s", cmd)

    child_pid = os.fork()
    if child_pid == 0:
        logger.info("Child pid = %s", os.getpid())
        p = subprocess.Popen(cmd, shell=True, universal_newlines=True, stderr=subprocess.STDOUT, stdout=subprocess.PIPE)
    
        while p.poll() is None:
            line = p.stdout.readline()
            if verbose:
                logger.info("%s", line.strip())

        sys.exit(0)

    else:
        logger.info("Parent pid = %s", os.getpid())
        signal.signal(signal.SIGINT, signal.SIG_IGN)
        os.waitpid(child_pid, 0)

    #return p

def shell_exec(cmd, verbose=True):
    """ Run the command and return output as string """

    if verbose:
        logger.critical("$ %s", cmd)
    try:
        r = subprocess.check_output(cmd, stderr=subprocess.STDOUT, shell=True)
    except subprocess.CalledProcessError, e:
        r = str(e.output)
    if verbose:
        for line in r.split("\n"):
            logger.info("%s", line)
    return r

def param_reader(filename):
    """ Read ini-like parameter file. (key = value) """
    kv = {}
    with open(filename) as f:
        for line in f:
            l = line.strip().split("#")[0]
            #print("line = %s" % l)
            key, value = l.partition("=")[::2]
            if len(key.strip()) > 0 and len(value.strip()) > 0:
                kv[key.strip()] = value.strip()
    return kv

def get_machines(hostfile, num_machines):
    machines = []
    n = 0
    with open(hostfile) as f:
        for line in f:
            if n >= num_machines:
                return machines
            n += 1
            machines.append(line.strip())
    assert len(machines) <= num_machines, "Number of machines in host file is less than requested."
    return machines

def implode(char, tokens):
    """
    Join list of tokens with given char
    """
    return char.join(tokens)

def mkdirp(path):
    """
    Creates the folder if not already present.
    """
    logger.info("Creating directory %s", path)
    if not os.path.isdir(path):
        os.mkdir(path)

def chdir(path):
    """
    Move to the directory if exists
    """
    logger.info("Move to directory %s", path)
    if os.path.isdir(path):
        os.chdir(path)

def copyfile(dest_dir, filename):
    """
    Copy filename to dest_dir
    """
    logger.info("Copying %s to %s", os.path.basename(filename), dest_dir)
    shutil.copy2(filename, "%s/%s" % (dest_dir, os.path.basename(filename)))

# Logging
# From Karthik's Distalyzer code.

LOG_FORMAT_STR = '%(asctime)s [%(levelname)s::%(module)s::%(funcName)s] %(message)s'
LOG_FORMAT_COLOR_STR = '\033[1;33m%(asctime)s\033[0m %(color)s[%(levelname)s::%(module)s::%(funcName)s]\033[0m %(message)s'

class ColorFormatter(logging.Formatter):
    COLOR_MAP = {
            'CRITICAL': '\033[1;31m',  # red
            'ERROR': '\033[1;31m',  # red
            'WARNING': '\033[1;31m',  # red
            'INFO': '\033[1;36m',  # cyan
            'DEBUG': '\033[1;35m',  # magenta
            }
    def __init__(self, fmt):
        logging.Formatter.__init__(self, fmt)
        return

    def format(self, record):
        # Color the 
        record.color = ColorFormatter.COLOR_MAP[record.levelname]
        #record.levelname = '%s%s%s' % (
                #ColorFormatter.COLOR_MAP[record.levelname],
                #record.levelname,
                #'\033[0m'  # end-color
                #)

        return logging.Formatter.format(self, record)

log_configured = None
def configureLogging(root_name='Benchmark',
                     output_file=None,
                     decorate_header=True,
                     log_stdout=True):
    global log_configured
    if log_configured:
        return
    log_configured = True
    root = logging.getLogger(root_name)
    root.setLevel(logging.DEBUG)

    # Stdout logging
    if log_stdout:
        console = logging.StreamHandler(sys.stdout)
        formatter = ColorFormatter(LOG_FORMAT_COLOR_STR)
        console.setFormatter(formatter)
        root.addHandler(console)

    if output_file:
        dir_path = os.path.dirname(output_file)
        if dir_path \
                and not os.path.isdir(dir_path):
            assert False,\
                    "Directory path does not exist!: '%s'" % dir_path
        # File logging
        fout = logging.FileHandler(output_file)
        formatter = logging.Formatter(LOG_FORMAT_STR)
        fout.setFormatter(formatter)
        root.addHandler(fout)

    if decorate_header:
        # Signify start of new log
        root.info('')
        root.info('=' * 80)
        root.info('')
    return
