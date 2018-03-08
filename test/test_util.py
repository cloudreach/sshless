import pytest
from sshless.util import read_filter


@pytest.mark.usefixtures('homedir')
def test_read_filter_file_not_exist():
    result = read_filter()
    assert result == {}
