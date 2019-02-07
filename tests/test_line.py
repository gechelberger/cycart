import pytest

from cycart import Line, P2

def test_create():

    line = Line(5, 5, 0)

    assert line.a == 1
    assert line.b == 1
    assert line.c == 0

    with pytest.raises(ValueError):
        Line(0, 0, 0)

@pytest.mark.skip()
def test_temporary_bug_in_line_coefficients():

    with pytest.raises(ValueError):
        Line(0, 0, 20)

def test_line_equality():

    line = Line(1, -1, 0)

    assert line == Line(-1, 1, 0)
    assert line != Line(1, 1, 0)
    assert line != None

def test_create_from_points():
    l = Line.ByPoints(P2(-1, -1), P2(1, 1))

    assert l.a == -1
    assert l.b == 1
    assert l.c == 0

    l = Line.ByPoints(P2(-1, 1), P2(1, -1))

    assert l.a == 1
    assert l.b == 1
    assert l.c == 0

    l = Line.ByPoints(P2(-1, 1), P2(1, 1))

    assert l.a == 0
    assert l.b == 1
    assert l.c == 1

    l = Line.ByPoints(P2(1, -1), P2(1, 1))

    assert l.a == 1
    assert l.b == 0
    assert l.c == 1

    with pytest.raises(ValueError):
        Line.ByPoints(P2(1, 1), P2(1, 1))



def test_xy_of():
    l = Line(-1, 1, 0)

    assert l.y_of_x(1) == pytest.approx(1)
    assert l.y_of_x(-1) == pytest.approx(-1)
    assert l.x_of_y(1) == pytest.approx(1)
    assert l.x_of_y(-1) == pytest.approx(-1)

    assert l.y_of_x(25) == pytest.approx(25)
    assert l.y_of_x(-25) == pytest.approx(-25)
    assert l.x_of_y(25) == pytest.approx(25)
    assert l.x_of_y(-25) == pytest.approx(-25)

    l = Line(1, 1, 0)

    assert l.y_of_x(1) == pytest.approx(-1)
    assert l.y_of_x(-1) == pytest.approx(1)
    assert l.x_of_y(1) == pytest.approx(-1)
    assert l.x_of_y(-1) == pytest.approx(1)

    assert l.y_of_x(25) == pytest.approx(-25)
    assert l.y_of_x(-25) == pytest.approx(25)
    assert l.x_of_y(25) == pytest.approx(-25)
    assert l.x_of_y(-25) == pytest.approx(25)



def test_degenerate_xy_of_cases():
    vert = Line.ByPoints(P2(1, 1), P2(1, -1))

    assert vert.y_of_x(1) is None
    assert vert.y_of_x(-100) is None
    assert vert.x_of_y(-1) == pytest.approx(1)
    assert vert.x_of_y(1) == pytest.approx(1)
    assert vert.x_of_y(-100) == pytest.approx(1)
    assert vert.x_of_y(100) == pytest.approx(1)

    horz = Line.ByPoints(P2(-1, 0), P2(1, 0))

    assert horz.y_of_x(-1) == pytest.approx(0)
    assert horz.y_of_x(1) == pytest.approx(0)
    assert horz.y_of_x(-100) == pytest.approx(0)
    assert horz.y_of_x(100) == pytest.approx(0)

    assert horz.x_of_y(-1) is None
    assert horz.x_of_y(1) is None
    assert horz.x_of_y(-100) is None
    assert horz.x_of_y(100) is None