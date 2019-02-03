import pytest
import math

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

def test_v2_sub():
    v1 = V2(100, 200)
    v2 = V2(1, 2)

    v3 = v1 - v2
    assert v3.x == 99
    assert v3.y == 198

    v3 = v2 - v1
    assert v3.x == -99
    assert v3.y == -198

    with pytest.raises(TypeError):
        v1 - 1

    with pytest.raises(TypeError):
        1 - v1

    with pytest.raises(TypeError):
        v1 - None

    with pytest.raises(TypeError):
        None - v1

def test_v2_mul():
    v1 = V2(5, 10)

    v2 = v1 * 10
    assert v2.x == 50
    assert v2.y == 100

    v2 = 10 * v1
    assert v2.x == 50
    assert v2.y == 100

    with pytest.raises(TypeError):
        v1 * v1

    with pytest.raises(TypeError):
        v1 * None

    with pytest.raises(TypeError):
        None * v1

def test_v2_div():
    v1 = V2(5, 10)

    v2 = v1 / 5
    assert v2.x == 1
    assert v2.y == 2

    v2 = 5 / v1
    assert v2.x == 1
    assert v2.y == 0.5

    with pytest.raises(TypeError):
        v1 / v1

    with pytest.raises(TypeError):
        v1 / None

    with pytest.raises(TypeError):
        None / v1

    with pytest.raises(ZeroDivisionError):
        v1 / 0

def test_v2_approx():
    v1 = V2(5, 10)

    assert v1.approx(v1)

    assert v1.approx(V2(5.0000000001, 10.0000000001))

    assert not v1.approx(V2(5.0000001, 10.0000001))

    #todo

def test_v2_rotated():
    v1 = V2(1, 0)

    assert v1.rotated(math.pi / 2).approx(V2(0, 1))
    assert v1.rotated(math.pi).approx(V2(-1, 0))
    assert v1.rotated(math.pi * 3 / 2).approx(V2(0, -1))
    assert v1.rotated(2 * math.pi).approx(v1)

    with pytest.raises(TypeError):
        v1.rotated(None)

    with pytest.raises(TypeError):
        v1.rotated(v1)

def test_v2_dot():
    v1 = V2(2, 3)
    v2 = V2(4, 5)

    assert v1.dot(v2) == 2 * 4 + 3 * 5

    with pytest.raises(TypeError):
        v1.dot(1)

    with pytest.raises(TypeError):
        v1.dot(None)

def test_v2_cross():
    v1 = V2(2, 3)
    v2 = V2(4, 5)

    assert v1.cross(v2) == 2 * 5 - 3 * 4
    assert v2.cross(v1) == 4 * 3 - 2 * 5

    with pytest.raises(TypeError):
        v1.cross(1)

    with pytest.raises(TypeError):
        v1.cross(None)

