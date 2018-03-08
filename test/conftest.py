from click.testing import CliRunner
import os
import pytest
from sshless.core import SSHLess
from sshless.cli import cli


@pytest.fixture(scope='session')
def sshless_app():
    return SSHLess({'iam': '', 'region': 'eu-central-1'})


@pytest.fixture()
def homedir(tmpdir):
    save_home = os.environ.get('HOME', '')
    os.environ['HOME'] = str(tmpdir)
    yield tmpdir
    os.environ['HOME'] = save_home


@pytest.fixture(scope='session')
def sshless_cmd(request):
    args, env = request.param
    runner = CliRunner()
    yield runner.invoke(cli=cli, args=args)
