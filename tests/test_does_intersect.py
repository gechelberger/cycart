import pytest

from cycart import Line, Circle, LineSegment, P2, does_intersect

def test_does_intersect_line_line():
    l45 = Line(1, -1, 0)
    l0 = Line(0, 1, 0)
    l90 = Line(1, 0, 0)

    l45_up = Line(1, -1, 10)

    assert does_intersect(l45, l0)
    assert does_intersect(l90, l0)

    assert not does_intersect(l45, l45_up)

    with pytest.raises(ValueError):
        does_intersect(l45, l45)


def test_does_intersect_line_circle():
    circle = Circle(99, P2(100, 100))

    assert not does_intersect(circle, Line(1, 1, 0))
    assert not does_intersect(Line(1, 1, 0), circle)

    assert does_intersect(circle, Line(1, -1, 0))
    assert does_intersect(Line(1, -1, 0), circle)

    assert does_intersect(circle, Line(1, 0, 100))
    assert does_intersect(Line(1, 0, 100), circle)

    assert does_intersect(circle, Line(0, 1, 100))
    assert does_intersect(Line(0, 1, 100), circle)

    assert not does_intersect(circle, Line(1, 0, 0))
    assert not does_intersect(Line(1, 0, 0), circle)

    assert does_intersect(circle, Line(1, 0, 1))
    assert does_intersect(Line(1, 0, 1), circle)


def test_does_intersect_line_segment_line_segment():
    ls45 = LineSegment(P2(-1, -1), P2(1, 1))
    ls135 = LineSegment(P2(-1, 1), P2(1, -1))
    assert does_intersect(ls45, ls135)

    ls135_up2 = LineSegment(P2(-1, 3), P2(1, 1))
    assert does_intersect(ls45, ls135_up2)

    ls135_up3 = LineSegment(P2(-1, 4), P2(1, 2))
    assert not does_intersect(ls45, ls135_up3)


def test_does_intersect_circle_circle():

    c1 = Circle(100)
    c2 = Circle(100, P2(500, 500))
    assert not does_intersect(c1, c2)
    assert not does_intersect(c1, Circle(50))

    assert does_intersect(c1, Circle(100, P2(10, 10)))


def test_does_intersect_line_line_segment():
    line = Line(1, 0, 0)
    x_ls = LineSegment(P2(-1, 0), P2(1, 0))
    p_ls = LineSegment(P2(-1, -1), P2(-1, 1))

    assert does_intersect(line, x_ls)
    assert does_intersect(x_ls, line)

    assert not does_intersect(line, p_ls)
    assert not does_intersect(p_ls, line)

    with pytest.raises(ValueError):
        does_intersect(line, LineSegment(P2(0, 0), P2(0, 1)))


def test_does_intersect_circle_line_segment():
    circle = Circle(100)

    ls_right = LineSegment(P2(50, 0), P2(150, 0))
    assert does_intersect(circle, ls_right)
    assert does_intersect(ls_right, circle)

    ls_left = LineSegment(P2(-50, -50), P2(-100, -100))
    assert does_intersect(circle, ls_left)
    assert does_intersect(ls_left, circle)

    ls_inside = LineSegment(P2(-25, -25), P2(25, 25))
    assert not does_intersect(circle, ls_inside)
    assert not does_intersect(ls_inside, circle)

    ls_outside = LineSegment(P2(0, 175), P2(175, 0))
    assert not does_intersect(circle, ls_outside)
    assert not does_intersect(ls_outside, circle)


