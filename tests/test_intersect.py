import pytest

from cycart import Line, LineSegment, Circle, P2, intersect


def test_line_line():
    l1 = Line(1, 1, 0)
    l2 = Line(1, -1, 0)

    assert {P2(0, 0)} == intersect(l1, l2)

    assert {P2(1, 1)} == intersect(l2, Line(1, 1, 2))

    l3 = Line(1, 1, 20)
    assert set() == intersect(l1, l3)

    with pytest.raises(ValueError):
        intersect(l1, l1)


def test_line_line_segment():
    l1 = Line(1, 1, 0)

    assert {P2(0, 0)} == intersect(l1, LineSegment(P2(-10, -10), P2(10, 10)))
    assert {P2(0, 0)} == intersect(LineSegment(P2(-10, -10), P2(10, 10)), l1)
    assert {P2(0, 0)} == intersect(l1, LineSegment(P2(10, 10), P2(-10, -10)))
    assert {P2(0, 0)} == intersect(LineSegment(P2(10, 10), P2(-10, -10)), l1)

    assert set() == intersect(l1, LineSegment(P2(1, 1), P2(10, 10)))

    assert {P2(-1, 1)} == intersect(l1, LineSegment(P2(-1, 1), P2(20, 20)))

def test_line_line_segment_degenerate():
    l1 = Line(1, 1, 0)

    with pytest.raises(ValueError):
        intersect(l1, LineSegment(P2(0, 0), P2(-10, 10)))


def test_line_segment_line_segment():
    ls1 = LineSegment(P2(0, 0), P2(10, 10))
    ls2 = LineSegment(P2(0, 10), P2(10, 0))

    assert {P2(5, 5)} == intersect(ls1, ls2)
    assert {P2(5, 5)} == intersect(ls2, ls1)

    with pytest.raises(NotImplementedError):
        intersect(ls1, None)

    assert set() == intersect(ls1, LineSegment(P2(0, 5), P2(5, 10)))

def test_line_segment_line_segment_edge_cases():
    ls1 = LineSegment(P2(0, 0), P2(10, 10))

    assert {P2(0, 0)} == intersect(ls1, LineSegment(P2(-1, 1), P2(0, 0)))
    assert {P2(10, 10)} == intersect(ls1, LineSegment(P2(10, 10), P2(10, 20)))

    with pytest.raises(ValueError):
        intersect(ls1, ls1)

    with pytest.raises(ValueError):
        intersect(ls1, LineSegment(P2(0,0), P2(5, 5)))

    with pytest.raises(ValueError):
        intersect(ls1, LineSegment(P2(5, 5), P2(10, 10)))

    with pytest.raises(ValueError):
        intersect(ls1, LineSegment(P2(4, 4), P2(6, 6)))

    with pytest.raises(ValueError):
        intersect(ls1, LineSegment(P2(-1, -1), P2(11, 11)))

def test_ls2_ls2_colinear_edge_case():
    ls1 = LineSegment(P2(0, 0), P2(10, 10))
    assert {P2(10, 10)} == intersect(ls1, LineSegment(P2(10, 10), P2(15, 15)))
    assert {P2(0, 0)} == intersect(ls1, LineSegment(P2(-5, -5), P2(0, 0)))


def test_line_circle():
    circle = Circle(100, P2(1, 1))
    x = Line(1, 0, 1)

    points = intersect(x, circle)
    assert {P2(1.0, 101.0), P2(1.0, -99.0)} == points

    points = intersect(circle, x)
    assert {P2(1.0, 101.0), P2(1.0, -99.0)} == points

    tangent_circle = Circle(1, P2(2, 0))
    assert {P2(1.0, 0.0)} == intersect(tangent_circle, x)
    assert {P2(1.0, 0.0)} == intersect(x, tangent_circle)

    horz = Line(0, 1, 1)
    assert {P2(-99.0, 1.0), P2(101, 1.0)} == intersect(horz, circle)
    assert {P2(-99.0, 1.0), P2(101, 1.0)} == intersect(circle, horz)

    far_line = Line(1, 0, 200)
    assert set() == intersect(far_line, circle)
    assert set() == intersect(circle, far_line)


def test_line_segment_circle():
    circle = Circle(100, P2(1, 0))
    x = LineSegment(P2(1, -1000), P2(1, 1000))

    points = intersect(x, circle)
    assert {P2(1.0, 100.0), P2(1.0, -100.0)} == points

    points = intersect(circle, x)
    assert {P2(1.0, 100.0), P2(1.0, -100.0)} == points

    x2 = LineSegment(P2(1, -1000), P2(1, 0))
    assert {P2(1.0, -100.0)} == intersect(circle, x2)

    assert {P2(1.0, -100.0)} == intersect(x2, circle)


def test_circle_circle():
    # functionality tested in test_r2_circle

    circle1 = Circle(100, P2(0, 0))
    circle2 = Circle(100, P2(100, 100))

    assert {P2(0.0, 100.0), P2(100.0, 0.0)} == intersect(circle1, circle2)


"""
def test_polygon_line():
    polygon = Polygon([P2(-1, -1), P2(1, -1), P2(1, 1), P2(-1, 1)])

    line = Line(1, 1, 0)

    assert {P2(-1, 1), P2(1, -1)} == intersect(polygon, line)
    assert {P2(-1, 1), P2(1, -1)} == intersect(line, polygon)

    line = Line(1, 1, 1)

    assert {P2(0, 1), P2(1, 0)} == intersect(polygon, line)
    assert {P2(0, 1), P2(1, 0)} == intersect(line, polygon)


def test_polygon_line_segment():
    polygon = Polygon([P2(-1, -1), P2(1, -1), P2(1, 1), P2(-1, 1)])

    ls = LineSegment(P2(0, 0), P2(10, 0))
    assert {P2(1.0, 0.0)} == intersect(polygon, ls)
    assert {P2(1.0, 0.0)} == intersect(ls, polygon)

    ls = LineSegment(P2(-0.5, -0.5), P2(0.5, 0.5))
    assert set() == intersect(polygon, ls)
    assert set() == intersect(ls, polygon)

    ls = LineSegment(P2(0, 0), P2(-10, -10))
    assert {P2(-1.0, -1.0)} == intersect(polygon, ls)
    assert {P2(-1.0, -1.0)} == intersect(ls, polygon)

    ls = LineSegment(P2(0, -10), P2(0, 10))
    assert {P2(0.0, -1.0), P2(0.0, 1.0)} == intersect(polygon, ls)
    assert {P2(0.0, -1.0), P2(0.0, 1.0)} == intersect(ls, polygon)
"""