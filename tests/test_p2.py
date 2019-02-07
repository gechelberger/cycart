import pytest
import math

from cycart import P2, V2

def test_p2_create():
    p = P2(100, 200)

    assert p.x == 100
    assert p.y == 200

def test_p2_as_vector():
    p = P2(100, 200)

    vector = p.vector()
    assert isinstance(vector, V2)
    assert vector.x == 100
    assert vector.y == 200

def test_p2_ccw():
    p1 = P2(-1, 1)
    p2 = P2(0, 0)
    p3 = P2(1, 1)

    assert P2.CCW(p1, p2, p3) > 0
    assert P2.CCW(p3, p2, p1) < 0

def test_p2_angle():
    p1 = P2(-1, 1)
    p2 = P2(0, 0)
    p3 = P2(1, 1)

    angle = P2.Angle(p1, p2, p3)

    assert math.isclose(angle, math.pi / 2)

def test_p2_rotate():
    point = P2(2, 2)

    assert point.rotate(math.pi).approx(P2(-2, -2))

    assert point.rotate(math.pi, P2(1, 1)).approx(P2(0, 0))

    with pytest.raises(TypeError):
        point.rotate(point)

    with pytest.raises(TypeError):
        point.rotate(None)

def test_p2_eq():
    assert P2(0, 0) == P2(0, 0)

    assert P2(0, 0) != V2(0, 0)

    assert P2(0, 0) != None

    assert None != P2(0, 0)