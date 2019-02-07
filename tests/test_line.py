import pytest

from cycart import Line, P2

def test_create():

    line = Line(5, 5, 0)

    assert line.a == 1
    assert line.b == 1
    assert line.c == 0

    with pytest.raises(ValueError):
        Line(0, 0, 0)

def test_line_equality():

    line = Line(1, -1, 0)

    assert line == Line(-1, 1, 0)
    assert line != Line(1, 1, 0)
    assert line != None