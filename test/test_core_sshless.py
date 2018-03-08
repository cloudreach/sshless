import pytest
from operator import itemgetter
from sshless.core import SSHLess


@pytest.mark.parametrize("cfg", [pytest.mark.xfail({}), pytest.mark.xfail('string'), pytest.mark.xfail([('iam', 'something')]),
                                 pytest.mark.xfail({'iam': 'something'}), pytest.mark.xfail({'iam': ''}), {'iam': '', 'region': 'something'}],
                         ids=['an empty config obj', 'a string as config', 'not a dict but iterable',
                              'iam role', 'empty iam role name', 'empty iam but with region'])
def test_create_sshless_app(cfg):
    assert SSHLess(cfg) is not None, 'Failed to create the app instance'

#
# @pytest.mark.vcr()
# @pytest.mark.parametrize('command_id', [pytest.mark.xfail('empty'), '7ce628a4-e96c-4a52-88be-027750b6bf58'])
# def test_list_commands_ok(sshless_app, command_id):
#     if command_id == 'empty':
#         cmds = sshless_app.list_commands()
#     else:
#         cmds = sshless_app.list_commands(command_id)
#
#     assert len(cmds) > 0
#     assert '7ce628a4-e96c-4a52-88be-027750b6bf58' in [cmd['CommandId'] for cmd in cmds]
