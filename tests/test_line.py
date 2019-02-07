import pytest

from cycart import Line, P2, V2

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


def test_intersection2():

    l1 = Line(1, 1, 0)
    l2 = Line(1, -1, 0)

    assert l1.intersect(l2).approx(P2(0, 0))
    assert l2.intersect(l1).approx(P2(0, 0))

    l3 = Line(1, 1, 1)

    assert l1.intersect(l3) is None

    with pytest.raises(TypeError):
        l1.intersect(None)

def test_intersection():
    horz = Line.ByPoints(P2(-1, 10), P2(1, 10))
    vert = Line.ByPoints(P2(10, -1), P2(10, 1))

    assert horz.intersect(vert).approx(P2(10, 10))

    assert horz.intersect(horz) is None
    assert horz.intersect(Line.ByPoints(P2(-1, 0), P2(1, 0))) is None

    l45 = Line.ByPoints(P2(0, 0), P2(1, 1))
    assert horz.intersect(l45).approx(P2(10, 10))

    l135 = Line.ByPoints(P2(0, 0), P2(-1, 1))
    assert horz.intersect(l135).approx(P2(-10, 10))


def test_closest_point():
    horz = Line.ByPoints(P2(-1, 10), P2(1, 10))

    assert horz.closest_point(P2(0, 0)).approx(P2(0, 10))
    assert horz.closest_point(P2(5, 10)).approx(P2(5, 10))

    vert = Line.ByPoints(P2(10, 1), P2(10, -2))

    assert vert.closest_point(P2(0, 5)).approx(P2(10, 5))
    assert vert.closest_point(P2(10, 5)).approx(P2(10, 5))


def test_translate():
    line = Line(2, 1, 2)
    assert line.y_of_x(0) == pytest.approx(2)
    assert line.x_of_y(0) == pytest.approx(1)

    translated = line.translate(V2(1, 1))
    assert translated.y_of_x(0) == pytest.approx(3)
    assert translated.x_of_y(0) == pytest.approx(2)

    horz = Line.ByPoints(P2(-1, 10), P2(1, 10))
    assert horz.y_of_x(0) == pytest.approx(10)

    translated = horz.translate(V2(1, 1))
    assert translated.y_of_x(0) == pytest.approx(11)

    vert = Line.ByPoints(P2(10, -1), P2(10, 1))
    assert vert.x_of_y(0) == pytest.approx(10)

    translated = vert.translate(V2(1, 1))
    assert translated.x_of_y(0) == pytest.approx(11)



def test_parallel_y():
    line = Line.ByPoints(P2(0, 0), P2(1, 0))

    up_one = line.parallel(P2(1, 1))

    assert up_one == line.parallel(P2(0, 1))

    assert up_one.a == 0
    assert up_one.b == 1
    assert up_one.c == 1

def test_parallel_x():
    line = Line.ByPoints(P2(0, 0), P2(0, 1))

    over_one = line.parallel(P2(1, 0))

    assert over_one.a == 1
    assert over_one.b == 0
    assert over_one.c == 1

def test_parallel_xy():
    line = Line(1, 1, 0)

    up_and_over = line.parallel(P2(1, 1))

    assert up_and_over.a == 0.5
    assert up_and_over.b == 0.5
    assert up_and_over.c == 1

def test_contains():

    line = Line(1, 1, 0)

    assert line.contains(P2(0, 0))
    assert line.contains(P2(-1, 1))
    assert line.contains(P2(1, -1))

    assert P2(0, 0) in line

    assert not line.contains(P2(0, 1))

    with pytest.raises(TypeError):
        line.contains(V2(0, 0))

    with pytest.raises(TypeError):
        line.contains(None)