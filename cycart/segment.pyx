from cycart.native.dtypes cimport _R2

from cycart.native.segment cimport (
    ls2_translate,
    ls2_rotate,
    ls2_vector,
    ls2_contains,
    ls2_approx,
    ls2_center,
    ls2_length,
    ls2_overlaps,
)

from cycart.native.intersect cimport (
    ls2_ls2_intersect
)

from cycart.native.line cimport (
    l2_ref_by_points,
)

from cycart.space cimport P2, V2, py_p2_new, py_v2_new
from cycart.space import P2, V2

from cycart.line cimport Line
from cycart.line import Line


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
        return py_p2_new(self.data.p1)

    @property
    def p2(self):
        return py_p2_new(self.data.p2)

    def __init__(LineSegment self, P2 p1, P2 p2):
        if p1 == p2:
            raise ValueError("LineSegment endpoints must be distinct.")
        self.data.p1 = p1.data
        self.data.p2 = p2.data

    def translate(LineSegment self, V2 vector not None) -> LineSegment:
        return py_seg_new(ls2_translate(self.data, vector.data))

    def rotate(LineSegment self, double radians, P2 center=None) -> LineSegment:
        cdef _R2 around = _R2(0, 0) if center is None else center.data
        return py_seg_new(ls2_rotate(self.data, around, radians))

    def line(LineSegment self) -> Line:
        cdef Line ret = Line.__new__(Line)
        if not l2_ref_by_points(ret.data, self.data.p1, self.data.p2):
            raise RuntimeError("unknown error")
        return ret

    def overlaps(LineSegment self, LineSegment other not None) -> bool:
        return ls2_overlaps(self.data, other.data)

    def vector(LineSegment self) -> V2:
        return py_v2_new(ls2_vector(self.data))

    def center(LineSegment self) -> P2:
        return py_p2_new(ls2_center(self.data))

    def length(LineSegment self) -> double:
        return ls2_length(self.data)

    def contains(LineSegment self, P2 point not None, double rtol=1e-9, atol=0):
        return ls2_contains(self.data, point.data, rtol, atol)

    def __contains__(LineSegment self, P2 point):
        return self.contains(point)

    def approx(LineSegment lhs, LineSegment rhs not None, double rtol=1e-9, atol=0):
        return ls2_approx(lhs.data, rhs.data, rtol, atol)

    def __eq__(lhs, rhs):
        if isinstance(lhs, LineSegment) and isinstance(rhs, LineSegment):
            return lhs.approx(rhs)
        return NotImplemented


