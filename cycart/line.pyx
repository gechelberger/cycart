from cycart.native.space cimport _R2

from cycart.native.line cimport (
    _Line,
    l2_ref_normalize,
    l2_ref_by_points,
    l2_ref_translate,
    l2_ref_parallel,
    l2_ref_perpendicular,
    l2_contains_point,
    l2_closest_point,
    l2_ref_f_of_x,
    l2_ref_f_of_y,
    l2_l2_intersect,
    l2_normal,
    l2_approx,
    l2_point_on_side,

)

from cycart.space cimport P2, V2, py_p2_new, py_v2_new
from cycart.space import P2, V2

cdef class Line:

    @staticmethod
    def ByPoints(P2 p1, P2 p2):
        cdef Line ret = Line.__new__(Line)
        if not l2_ref_by_points(ret.data, p1.data, p2.data): #P!
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
        if not l2_ref_normalize(self.data):
            raise ValueError("Invalid Line: %f x + %f y = %f" % (float(ca), float(cb), float(cc)))

    def translate(Line self, V2 displacement not None) -> Line:
        cdef Line ret = Line.__new__(Line)
        if not l2_ref_translate(ret.data, self.data, displacement.data):
            raise RuntimeError("Could not translate line... shouldn't happen")
        return ret

    def perpendicular(Line self, P2 point not None) -> Line:
        cdef Line ret = Line.__new__(Line)
        if not l2_ref_perpendicular(ret.data, self.data, point.data):
            raise ValueError("Could not find perpendicular line.")
        return ret

    def parallel(Line self, P2 point not None) -> Line:
        cdef Line ret = Line.__new__(Line)
        if not l2_ref_parallel(ret.data, self.data, point.data):
            raise RuntimeError("Could not find parallel line... shouldn't happen.")
        return ret

    def closest_point(Line self, P2 point not None) -> P2:
        cdef P2 ret = P2.__new__(P2)
        return py_p2_new(l2_closest_point(self.data, point.data))

    def contains(Line self, P2 point not None, double rtol=1e-9, double atol=0):
        return l2_contains_point(self.data, point.data, rtol, atol)

    def __contains__(Line self, P2 point not None) -> bool:
        return l2_contains_point(self.data, point.data)

    def does_intersect(Line self, Line other not None) -> bool:
        if self.approx(other):
            raise ValueError("Lines are identical")
        return (self.data.a * other.data.b - self.data.b * other.data.a) != 0

    def intersect(Line self, Line other not None) -> P2:
        cdef P2 ret = P2.__new__(P2)
        if not l2_l2_intersect(ret.data, self.data, other.data):
            return None
        return ret

    def f_of_y(Line self, double y) -> double:
        cdef double x
        if not l2_ref_f_of_y(x, self.data, y):
            return None
        return x

    def f_of_x(Line self, double x) -> double:
        cdef double y
        if not l2_ref_f_of_x(y, self.data, x):
            return None
        return y

    def point(Line self, x=None, y=None) -> P2:
        cdef P2 ret = P2.__new__(P2)
        if isinstance(x, (float, int)):
            if l2_ref_f_of_x(ret.data.y, self.data, x):
                ret.data.x = x
                return ret

        if isinstance(y, (float, int)):
            if l2_ref_f_of_y(ret.data.x, self.data, y):
                ret.data.y = y
                return ret

        raise ValueError("Can't create point from x or y", x, y)


    def normal(Line self) -> V2:
        return py_v2_new(l2_normal(self.data))

    def on_side(Line self, P2 point not None):
        return l2_point_on_side(self.data, point.data)

    def __eq__(lhs, rhs):
        if isinstance(lhs, Line) and isinstance(rhs, Line):
            return lhs.approx(rhs)
        return NotImplemented

    def approx(Line lhs not None, Line rhs not None) -> bool:
        return l2_approx(lhs.data, rhs.data)
