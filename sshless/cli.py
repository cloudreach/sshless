# !/usr/bin/env python

import sys
import logging
import time
import os
from functools import wraps
import click
from . core import SSHLess
from . util import *
from termcolor import colored


# Setup simple logging for INFO
logging.getLogger("botocore").setLevel(logging.CRITICAL)
logger = logging.getLogger("sshless")
handler = logging.StreamHandler(sys.stdout)
FORMAT = "[%(asctime)s][%(levelname)s] %(message)s"
handler.setFormatter(logging.Formatter(FORMAT))
logger.addHandler(handler)
logger.setLevel(logging.WARN)


def catch_exceptions(func):
    @wraps(func)
    def decorated(*args, **kwargs):
        """
        Invokes ``func``, catches expected errors, prints the error message and
        exits sceptre with a non-zero exit code.
        """
        try:
            return func(*args, **kwargs)
        except:
            # logger.error(sys.exc_info()[1])
            click.echo("[{}][{}] {}".format(time.strftime("%Y-%m-%d %H:%M:%S"),
                                            colored("ERROR", "red"),
                                            sys.exc_info()[1]
                                            ))
            sys.exit(1)

    return decorated


@click.group()
@click.version_option(prog_name="sshless")
@click.pass_context
@click.option(
    "--iam", default=os.environ.get("AWS_SSM_ROLE", ""), help="IAM to assume")
@click.option(
    "--region",
    default=os.environ.get("AWS_DEFAULT_REGION", "eu-west-1"),
    help="AWS region")
@click.option('-v', '--verbose', is_flag=True, multiple=True)
def cli(ctx, iam, region, verbose):
    ctx.obj = {
        "options": {},
        "region": region,
        "iam": iam,
        "verbosity": len(verbose)
    }

    if ctx.obj["verbosity"] == 1:
        logger.setLevel(logging.INFO)
    elif ctx.obj["verbosity"] > 1:
        logger.setLevel(logging.DEBUG)
        logger.debug("log level is set to DEBUG")
        logger.debug(ctx.obj)
    pass


@cli.command()
@click.option('-f', '--filters', default="PingStatus=Online", help='advanced Filter default: PingStatus=Online')
@click.pass_context
@catch_exceptions
def list(ctx, filters):
    """SSM Managed instances Online"""

    sshless = SSHLess(ctx.obj)
    fl = []
    for ff in filters.split(","):
        key, val = ff.split("=")
        fl.append({"Key": key, "Values": [val]})

    response = sshless.ssm.describe_instance_information(
        Filters=fl
    )
    logger.info("Total instances: {}".format(
        len(response["InstanceInformationList"])))
    click.echo(format_json(response["InstanceInformationList"]))


@cli.command()
@click.option('-f', '--filters', default="DocumentType=Command", help='Document Filter default: DocumentType=Command')
@click.option('-a', '--all-details', is_flag=True, help='All details')
@click.option('-o', '--owner', is_flag=True, help='Show owner')
@click.option('-P', '--platform', is_flag=True, help='Show platform types')
@click.option('-d', '--doc-version', is_flag=True, help='Show document version')
@click.option('-t', '--doc-type', is_flag=True, help='Show document type')
@click.option('-s', '--schema', is_flag=True, help='Show schema version')
@click.pass_context
@catch_exceptions
def docs(ctx, filters, all_details, owner, platform, doc_version, doc_type, schema):
    """List SSM documents"""
    sshless = SSHLess(ctx.obj)
    fl = []
    for ff in filters.split(","):
        key, val = ff.split("=")
        fl.append({"key": key, "value": val})
    docs = sshless.list_documents(fl)
    param_map = {
        'owner': 'Owner',
        'platform': 'PlatformTypes',
        'doc_version': 'DocumentVersion',
        'doc_type': 'DocumentType',
        'schema': 'SchemaVersion'
    }
    output = []
    if all_details:
        output = docs
    else:
        for d in docs:
            doc_info = [{"Name": d["Name"]}]
            for k, v in param_map.items():
                if ctx.params[k]:
                    doc_info.append({k: d[v]})
            output.append(doc_info)
    click.echo(format_json(output))


@cli.command()
@click.argument('ssm-document')
@click.option('-V', '--document-version', default=None, help='Document Version')
@click.pass_context
@catch_exceptions
def get(ctx, ssm_document, document_version):
    """Get SSM document"""
    sshless = SSHLess(ctx.obj)

    params = {'Name': ssm_document}
    if document_version:
        params['DocumentVersion'] = version
    doc = sshless.ssm.get_document(**params)

    doc_info = doc['Name']
    if 'DocumentVersion' in doc:
        doc_info += ' v{}'.format(doc['DocumentVersion'])
    if 'DocumentType' in doc:
        doc_info += ' {}'.format(doc['DocumentType'])
    click.echo("Name: {}".format(doc_info))
    click.echo(doc['Content'])


@cli.command()
@click.argument('command')
@click.option('-s', '--show-stats', is_flag=True, default=False)
@click.option('-n', '--name', default=os.environ.get("SSHLESS_NAME_FILTER", None), help='Filter based on tag:Name')
@click.option('-f', '--filters', default=os.environ.get("SSHLESS_FILTER", None), help='advanced Filter')
@click.option('-i', '--instances', default=os.environ.get("SSHLESS_ID_FILTER", None), help='instances ID')
@click.option('--maxconcurrency', default=None, help='Max concurrency allowed (Optional)')
@click.option('--maxerrors', default=1, help='Max errors allowed (default: 1)')
@click.option('--comment', default='sshless cli', help='Command invocation comment')
@click.option('--interval', default=1, help='Check interval (default: 1.0s)')
@click.option('--working-directory', default=None, help='workingDirectory')
@click.option('--timeout', default=600, help='TimeoutSeconds - If this time is reached and the command has not already started executing, it will not execute.')
@click.option('--s3-output', default=os.environ.get("SSHLESS_S3_OUTPUT", None), help='S3 output (Optional)')
@click.option('--s3-key', default=os.environ.get("SSHLESS_S3_KEY", ""), help='S3 Key (Optional)')
@click.option('--s3-region', default=os.environ.get("SSHLESS_S3_REGION", None), help='S3 region (Optional)')
@click.option('--preserve-s3-output', is_flag=True, default=False, help='Preserve S3 output (Optional)')
@click.pass_context
@catch_exceptions
def cmd(ctx, command, show_stats, name, filters, instances, maxconcurrency, maxerrors, comment, interval, working_directory, timeout, s3_output, s3_key, s3_region, preserve_s3_output):
    """SSM AWS-RunShellScript commands"""

    sshless = SSHLess(ctx.obj)
    if name and filters:
        click.echo("[{}] name and filters are mutually exclusive".format(
            colored("Error", "red")))
        sys.exit(1)

    fl = []
    params = {
        "DocumentName": "AWS-RunShellScript",
        "Parameters": {"commands": [command]},
        "Comment": comment,
        "MaxErrors": str(maxerrors),
        "TimeoutSeconds": int(timeout)
    }

    if instances:
        if name or filters:
            click.echo("[{}] instances filters override tag or advanced filter".format(
                colored("Warn", "yellow")))
        params["InstanceIds"] = instances.split(",")
        target = "InstanceIds: {}".format(instances)
        save_filter({"InstanceIds": params["InstanceIds"]})

    elif name:
        if filters:
            click.echo("[{}] name filter override advanced filter".format(
                colored("Warn", "yellow")))

        fl.append({'Key': 'tag:Name', 'Values': [name]})
        params["Targets"] = fl
        save_filter({"Targets": params["Targets"]})
        target = "Tag Name Filter: tag:Name={}".format(name)
    elif filters:
        for ff in filters.split(","):
            key, val = ff.split("=")
            fl.append({"Key": key, "Values": [val]})
        params["Targets"] = fl
        target = "Tag Filter: {}".format(filters)
        save_filter({"Targets": params["Targets"]})

    if all(v is None for v in [instances, name, filters]):
        cache_filter = read_filter()
        target = "Read from cache: {}".format(cache_filter)
        if cache_filter:
            logger.info("read filter from Cache: {}".format(cache_filter))
            params = dict(params.items() + cache_filter.items())
        else:
            raise ValueError("No valid Target - please check the online help")

    logger.debug("target: {}".format(target))

    if maxconcurrency:
        params["MaxConcurrency"] = str(maxconcurrency)

    if working_directory:
        params["Parameters"]["workingDirectory"] = [str(working_directory)]

    if s3_output:
        params["OutputS3BucketName"] = s3_output
    if s3_key:
        params["OutputS3KeyPrefix"] = s3_key
    if s3_region:
        params["OutputS3Region"] = s3_region

    cmd_result = sshless.send_command(params)
    cmd_id = cmd_result['Command']['CommandId']

    attempt = 0
    while True:
        time.sleep(0.2)
        attempt += 1
        if attempt % 10 == 0:
            logger.info(
                "attempt [{}] command {} is running please wait".format(attempt, cmd_id))

        out = sshless.list_commands(CommandId=cmd_id)[0]

        if out['Status'] not in ['Pending', 'InProgress']:
            if out['TargetCount'] == out['CompletedCount']:

                if out["TargetCount"] == 0:
                    click.echo(colored("TargetCount: 0", "red"))
                    sys.exit(1)

                logger.debug(sshless.command_url(cmd_id))
                logger.debug(format_json(out))

                if show_stats:
                    click.echo(get_report(out, target))

                res = sshless.list_command_invocations(cmd_id)
                if len(res) != 0:
                    if s3_output:
                        # lookup for the stdout file inside s3 bucket
                        status, instanceid, key, body = sshless.get_s3_output(
                            cmd_id, s3_output, s3_key, s3_region)
                        click.echo("[{}] {}".format(
                            get_status(status), instanceid))
                        click.echo(body)
                        if not preserve_s3_output:
                            # delete stdout file inside s3 bucket
                            sshless.delete_s3_output(key, s3_output, s3_region)

                    else:
                        for i in res:
                            click.echo("[{}] {} {}".format(get_status(
                                i['Status']), i['InstanceId'], i['InstanceName']))
                            for cp in i['CommandPlugins']:
                                click.echo(cp['Output'])
                break

        time.sleep(interval)
