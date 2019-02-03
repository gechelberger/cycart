import pytest

from cycart import V2

def test_v2_create():
    vector = V2(100, 200)

    assert vector.x == 100
    assert vector.y == 200

def test_v2_add():
    v1 = V2(100, 200)
    v2 = V2(1, 2)

    v3 = v1 + v2
    assert v3.x == 101
    assert v3.y == 202

    v3 = v2 + v1
    assert v3.x == 101
    assert v3.y == 202

    with pytest.raises(TypeError):
        v1 + 1

    with pytest.raises(TypeError):
        1 + v1

    with pytest.raises(TypeError):
        v1 + None

    with pytest.raises(TypeError):
        None + v1
