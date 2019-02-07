import pytest

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