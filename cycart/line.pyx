cimport cycart.ctypes as c

from cycart.space cimport P2, V2
from cycart.space import P2, V2

cdef class Line:

    @staticmethod
    def ByPoints(P2 p1, P2 p2):
        cdef Line ret = Line.__new__(Line)
        if not c.line_by_points(ret.data, p1.data, p2.data): #P!
            raise ValueError("Can not construct line on (%s, %s)." % (p1, p2))
        return ret

    @property
    def a(self):
        return self.data.a

    @property
    def b(self):
        return self.data.b

    @property
    def c(self):
        return self.data.c

    def __init__(Line self, double ca, double cb, double cc):
        self.data.a = ca
        self.data.b = cb
        self.data.c = cc
        if not c.line_normalize(self.data):
            raise ValueError("Invalid Line: %f x + %f y = %f" % (float(ca), float(cb), float(cc)))

    def translate(Line self, V2 displacement not None) -> Line:
        cdef Line ret = Line.__new__(Line)
        if not c.line_translate(ret.data, self.data, displacement.data):
            raise RuntimeError("Could not translate line... shouldn't happen")
        return ret

    def perpendicular(Line self, P2 point not None) -> Line:
        cdef Line ret = Line.__new__(Line)
        if not c.line_perpendicular(ret.data, self.data, point.data):
            raise ValueError("Could not find perpendicular line.")
        return ret

    def parallel(Line self, P2 point not None) -> Line:
        cdef Line ret = Line.__new__(Line)
        if not c.line_parallel(ret.data, self.data, point.data):
            raise RuntimeError("Could not find parallel line... shouldn't happen.")
        return ret

    def closest_point(Line self, P2 point not None) -> P2:
        cdef P2 ret = P2.__new__(P2)
        c.line_closest_point(ret.data, self.data, point.data)
        return ret

    def contains(Line self, P2 point not None, double rtol=1e-9, double atol=0):
        return c.line_contains_point(self.data, point.data, rtol, atol)

    def __contains__(Line self, P2 point not None) -> bool:
        return c.line_contains_point(self.data, point.data)

    def intersect(Line self, Line other not None) -> P2:
        cdef P2 ret = P2.__new__(P2)
        if not c.line_line_intersect(ret.data, self.data, other.data):
            return None
        return ret

    def x_of_y(Line self, double y) -> double:
        cdef double x
        if not c.line_x_of(x, self.data, y):
            return None
        return x

    def y_of_x(Line self, double x) -> double:
        cdef double y
        if not c.line_y_of(y, self.data, x):
            return None
        return y

    def normal(Line self) -> V2:
        cdef V2 ret = V2.__new__(V2)
        if not c.line_normal(ret.data, self.data):
            raise RuntimeError("unknown error")
        return ret

    def __eq__(lhs, rhs):
        if isinstance(lhs, Line) and isinstance(rhs, Line):
            return lhs.approx(rhs)
        return NotImplemented

    def approx(Line lhs not None, Line rhs not None) -> bool:
        return c.line_eq(lhs.data, rhs.data)

cdef class LineSegment:

    @property
    def x1(self):
        return self.data.p1.x

    @property
    def y1(self):
        return self.data.p1.y

    @property
    def x2(self):
        return self.data.p2.x

    @property
    def y2(self):
        return self.data.p2.y

    @property
    def p1(self):
        cdef P2 ret = P2.__new__(P2)
        ret.data = self.data.p1
        return ret

    @property
    def p2(self):
        cdef P2 ret = P2.__new__(P2)
        ret.data = self.data.p2
        return ret

    def __init__(LineSegment self, P2 p1, P2 p2):
        if p1 == p2:
            raise ValueError("LineSegment endpoints must be distinct.")
        self.data.p1 = p1.data
        self.data.p2 = p2.data

    def vector(LineSegment self):
        pass

    def center(LineSegment self):
        pass

    def intersect(LineSegment self, LineSegment other not None):
        pass

    def length(LineSegment self):
        pass

    def contains(LineSegment self, P2 point, double rtol=1e-9, atol=0):
        pass

    def __contains__(LineSegment self, P2 point):
        return self.contains(point)

    def approx(LineSegment lhs, LineSegment rhs not None, double rtol=1e-9, atol=0):
        return c.segment_eq(lhs.data, rhs.data, rtol, atol)

    def __eq__(lhs, rhs):
        if isinstance(lhs, LineSegment) and isinstance(rhs, LineSegment):
            return lhs.approx(rhs)
        return NotImplemented


