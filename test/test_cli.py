import pytest

@pytest.mark.vcr()
@pytest.mark.parametrize('sshless_cmd',
                         [
                             (("cmd", "--instances", "i-0b83e0b9f8f900500", '"ls"'), None)
                         ],
                         indirect=True)
def test_cmd_with_instances_ids(sshless_cmd):
    pass
    #
    # assert sshless_cmd.exit_code == 0
    # assert sshless_cmd.output_bytes == b'[Success] i-0b83e0b9f8f900500 \nbin\nboot\ncgroup\ndev\netc\nhome\nlib\nlib64\nlocal\nlost+found\nmedia\nmnt\nopt\nproc\nroot\nrun\nsbin\nselinux\nsrv\nsys\ntmp\nusr\nvar\n\n'
    #
    # assert sshless_cmd.output_bytes == b'Usage: cmd [OPTIONS] COMMAND\n\nError: Missing argument "command".\n'
