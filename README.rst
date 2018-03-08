====================
SSHLess with AWS SSM
====================

.. image:: https://travis-ci.org/cloudreach/sshless.svg?branch=master
    :target: https://travis-ci.org/cloudreach/sshless

.. image:: https://badge.fury.io/py/sshless.svg
    :target: https://badge.fury.io/py/sshless


Overview
--------

At re:invent 2017, many features were introduced such as `SSM PrivateLink <https://aws.amazon.com/blogs/aws/new-aws-privatelink-endpoints-kinesis-ec2-systems-manager-and-elb-apis-in-your-vpc/>`_, `PCI compliance <https://aws.amazon.com/blogs/security/aws-adds-16-more-services-to-its-pci-dss-compliance-program/>`_.
I decided to investigate on SSM and `SendCommand <https://docs.aws.amazon.com/systems-manager/latest/APIReference/API_SendCommand.html>`_ to understand its capabilities in a real world.
SSHLess is a python implementation of SSM SendCommand to simulate the usage of a normal CLI


Config
------

this script is designed to run across multiple accounts and across multiple regions you can switch between regions/accounts using some OS vars

To execute an assume role action
::

  $ export AWS_SSM_ROLE=arn:aws:iam::111111111:role/admin


Cache Filters
-------------

sshless use a local file to save the Target filters in order to simplify and avoid to have long command line history

Example::

  $ sshless cmd --name web-1 "uname -a"
  ..... output omitted ....
  $ cat ~/.sshless/filters     # local file with your filter
    {
    "Targets": [{
        "Key": "tag:Name",
        "Values": ["web-1"]
      }]
    }
  $ sshless cmd "uname -a"   # valid command to the same target
  ..... output omitted ....


Command
-------

Instance ID Filter::

  $ export SSHLESS_ID_FILTER=i-0da73e7c56e628889,i-0b83e0b9f8f900500
  $ sshless cmd "uname -a"

  $ sshless cmd  -i i-0da73e7c56e628889,i-0b83e0b9f8f900500 "uname -a"

Tag Name Filter::

  $ export SSHLESS_NAME_FILTER=web-1
  $ sshless cmd "uname -a"
  $ sshless cmd  --name web-1 "uname -a"

Advanced Tag filter::

  $ export SSHLESS_FILTER=tag:Role=web
  $ sshless cmd "uname -a"
  $ sshless cmd  --filters tag:Role=web "uname -a"

SSM Parameter store integration::

  $ sshless cmd  --name web-1 "echo {{ssm:example.parameter}}"

List of all SSM instances Online::

  $ sshless list


Execute command and save output to S3::

  $ sshless cmd  --name web-1 "uname -a" --s3-output=[your-s3-bucket-ssm-output]
  $ sshless cmd  --name web-1 "uname -a" --s3-output=[your-s3-bucket-ssm-output] --preserve-s3-output


============
SSHLess DEMO
============

Full Demo Lab is available `HERE <test/README.rst>`_

License
-------

sshless is licensed under the `Apache2 <LICENSE>`_.
