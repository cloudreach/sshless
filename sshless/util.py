#!/usr/bin/env python

import json
import os
from termcolor import colored


def get_status(status):
    if status == "Success":
        return colored(status, "green")
    else:
        return colored(status, "red")


def json_serial(obj):
    """JSON serializer for objects not serializable by default json code
    >>> from datetime import date, datetime
    >>> json_serial(date(2018, 12, 12))
    '2018-12-12'
    >>> json_serial(datetime(2018, 12, 12, 12, 12))
    '2018-12-12T12:12:00'
    >>> json_serial("")
    Traceback (most recent call last):
        ...
    TypeError: Type <class 'str'> not serializable
    """
    try:
        return obj.isoformat()
    except AttributeError:
        raise TypeError("Type %s not serializable" % type(obj))


def format_json(s):
    return json.dumps(s, indent=2, default=json_serial)


def get_report(i, target):
    return """[{}]
 CommandId: {}
 Requested: {}
 Command: {}
 {}
 Stats: Targets: {}  Completed: {}  Errors: {}
    """.format(get_status(i['Status']),
               i['CommandId'],
               i['RequestedDateTime'].replace(microsecond=0),
               i['Parameters']["commands"][0],
               target,
               i['TargetCount'],
               i['CompletedCount'],
               i['ErrorCount']
               )


def save_filter(target):
    base_path = "{}/.sshless".format(os.path.expanduser('~'))
    if not os.path.exists(base_path):
        os.makedirs(base_path)

    with open("{}/filter".format(base_path), 'w') as cache:
        cache.write(json.dumps(target, indent=2))


def read_filter():
    filter_file = "{}/.sshless/filter".format(os.path.expanduser('~'))
    if not os.path.exists(filter_file):
        return {}
    else:
        return json.load(open(filter_file))
