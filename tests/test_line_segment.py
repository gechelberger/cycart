import pytest

import math

from cycart import LineSegment, P2, V2

def test_create():
    ls1 = LineSegment(P2(10, 10), P2(0, 0))

    assert ls1.p1.approx(P2(10, 10))
    assert ls1.p2.approx(P2(0, 0))

    with pytest.raises(ValueError):
        LineSegment(P2(10, 10), P2(10, 10))

def test_eq():
    ls1 = LineSegment(P2(0, 0), P2(10, 10))
    ls2 = LineSegment(P2(10, 10), P2(0, 0))

    assert ls1 == ls1
    assert ls1 == ls2
    assert ls2 == ls1

    assert ls1 != None
    assert None != ls1


def test_line_segment_vector():
    ls = LineSegment(P2(0, 0), P2(10, 10))
    assert V2(10, 10) == ls.vector()

    ls = LineSegment(P2(10, 10), P2(0, 0))
    assert V2(-10, -10) == ls.vector()


def test_line_segment_length():
    ls = LineSegment(P2(0, 0), P2(10, 0))
    assert 10 == ls.length()

    ls = LineSegment(P2(0, 0), P2(0, 10))
    assert 10 == ls.length()

    ls = LineSegment(P2(-10, -10), P2(10, 10))
    assert 800 ** 0.5 == ls.length()


def test_line_segment_rotate():
    ls = LineSegment(P2(-10, -10), P2(10, 10))
    assert ls.rotate(math.pi / 2) == LineSegment(P2(-10, 10), P2(10, -10))

    ls = LineSegment(P2(0, 0), P2(10, 10))
    assert ls.rotate(math.pi / 2, P2(5, 5)) == LineSegment(P2(0, 10), P2(10, 0))


def test_line_segment_translate():
    ls = LineSegment(P2(-10, -10), P2(10, 10))
    assert LineSegment(P2(-9, -9), P2(11, 11)) == ls.translate(V2(1, 1))
    ls = LineSegment(P2(10, 10), P2(-10, -10))
    assert LineSegment(P2(11, 11), P2(-9, -9)) == ls.translate(V2(1, 1))


def test_line_segment_center():
    ls = LineSegment(P2(-10, 10), P2(10, 10))
    assert P2(0, 10) == ls.center()

    ls = LineSegment(P2(10, -10), P2(10, 10))
    assert P2(10, 0) == ls.center()

    ls = LineSegment(P2(-10, -10), P2(10, 10))
    assert P2(0, 0) == ls.center()


def test_line_segment_contains():
    ls = LineSegment(P2(-10, -10), P2(10, 10))
    assert ls.contains(P2(0, 0))

    assert ls.contains(P2(5, 5))
    assert ls.contains(P2(-10, -10))
    assert ls.contains(P2(10, 10))

    assert not ls.contains(P2(-11, -11))
    assert not ls.contains(P2(11, 11))
    assert not ls.contains(P2(1, 0))

    with pytest.raises(TypeError):
        ls.contains(V2(10, 10))

    with pytest.raises(TypeError):
        ls.contains(None)

    ls = LineSegment(P2(0, 0), P2(9999999999.9, 9999999999.9))
    assert ls.contains(P2(0, 0))
    assert ls.contains(P2(9999999999.9, 9999999999.9))


def test_line_segment_line():
    ls = LineSegment(P2(0, 0), P2(10, 10))

    line = ls.line()
    assert line.a == -1
    assert line.b == 1
    assert line.c == 0

    assert line == LineSegment(P2(-10, -10), P2(10, 10)).line()
    assert line == LineSegment(P2(100, 100), P2(200, 200)).line()

    assert line != LineSegment(P2(-10, -10), P2(1, 0)).line()


def test_line_segment_does_intersect():
    ls = LineSegment(P2(0, 0), P2(10, 10))

    assert ls.does_intersect(LineSegment(P2(0, 10), P2(10, 0)))

    assert not ls.does_intersect(LineSegment(P2(4, 5), P2(0, 10)))

    assert ls.does_intersect(LineSegment(P2(10, 10), P2(20, 20)))

    assert ls.does_intersect(LineSegment(P2(0, 0), P2(10, 10)))


def test_intersect():
    ls = LineSegment(P2(0, 0), P2(10, 10))

    with pytest.raises(TypeError):
        ls.intersect(None)

    with pytest.raises(TypeError):
        ls.intersect(ls.line())

    assert P2(5, 5) == ls.intersect(LineSegment(P2(0, 10), P2(10, 0)))

    assert None == ls.intersect(LineSegment(P2(4, 5), P2(0, 10)))

    assert None == ls.intersect(LineSegment(P2(5, 4), P2(10, 0)))

    ls = LineSegment(P2(10, 10), P2(0, 0))

    assert None == ls.intersect(LineSegment(P2(4, 5), P2(0, 10)))
    assert None == ls.intersect(LineSegment(P2(5, 4), P2(10, 0)))
