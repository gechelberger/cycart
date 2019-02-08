import pytest
import math

from cycart import Circle, P2, V2

def test_circle_create():

    circle = Circle(100)

    assert circle.radius == 100
    assert circle.center == P2(0, 0)

    circle = Circle(100, P2(100, 100))

    assert circle.radius == 100
    assert circle.center == P2(100, 100)

    with pytest.raises(TypeError):
        Circle(None)

def test_circle_properties():
    circle = Circle(100)

    assert circle.diameter == 200
    assert circle.circumference == pytest.approx(math.pi * 200)
    assert circle.area == pytest.approx(math.pi * 100 ** 2)

def test_circle_contains():
    circle = Circle(100)


    assert circle.contains(P2(-100, 0))
    assert circle.contains(P2(100, 0))
    assert circle.contains(P2(0, 100))
    assert circle.contains(P2(0, -100))


    assert not circle.contains(P2(150, 0))
    assert not circle.contains(P2(0, 150))

    with pytest.raises(TypeError):
        circle.contains(None)

    with pytest.raises(TypeError):
        circle.contains(V2(0, 0))