import pytest

from cycart import V2

def test_create_v2():
    vector = V2(100, 200)

    assert vector.x == 100
    assert vector.y == 200

