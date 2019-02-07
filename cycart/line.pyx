cimport cycart.ctypes as c

from cycart.space cimport P2, V2
from cycart.space import P2, V2

cdef class Line:

    @staticmethod
    def ByPoints(P2 p1, P2 p2):
        cdef Line ret = Line.__new__(Line)
        if not c.line_by_points(ret.data, p2.data, p2.data):
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

    def __init__(Line self, double a, double b, double c):
        self.data.a = a
        self.data.b = b
        self.data.c = c
        if not c.normalize_coefficients(<double*>&self.data, 3):
            raise ValueError("Invalid Line: %f x + %f y = %f" % (a, b, c))

    cpdef Line translate(Line self, V2 displacement):
        pass

    cpdef Line perpendicular(Line self, P2 point):
        pass

    cpdef Line parallel(Line self, P2 point):
        pass

    cpdef P2 closest_point(Line self, P2 point):
        pass

    def __contains__(Line self, P2 point not None):
        pass

    def intersect(Line self, Line other not None):
        pass

    def x_of(Line self, double y):
        pass

    def y_of(Line self, double x):
        pass

    def normal(Line self):
        pass

    def __eq__(Line lhs not None, Line rhs not None):
        pass

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

    def __eq__(LineSegment lhs not None, LineSegment rhs not None):
        pass


