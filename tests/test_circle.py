import pytest

from cycart import Circle, P2

def test_circle_create():

    circle = Circle(100)

    assert circle.radius == 100
    assert circle.center == P2(0, 0)

    circle = Circle(100, P2(100, 100))

    assert circle.radius == 100
    assert circle.center == P2(100, 100)

    with pytest.raises(TypeError):
        Circle(None)