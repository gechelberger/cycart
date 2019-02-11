cimport cython

from libcpp.vector cimport vector

from libc.math cimport sin, cos, fabs

from cycart.native.dtypes cimport _R2, _LineSegment
from cycart.native.space cimport r2_sub, r2_add, r2_cross, r2_approx, r2_ccw, r2_cmp_points
from cycart.native.segment cimport ls2_length, ls2_contains

from .space cimport P2, V2, py_p2_new, py_p2_extract
from .space import P2, V2
from .segment cimport py_seg_new

from .sequence cimport P2Sequence, r2_buffer
from .sequence import P2Sequence

from typing import Iterable

from .alg.convexhull cimport _jarvis_march_convexhull

"""
"""


cdef vector[_R2] roll(object[_R2, ndim=1] src, long shift):
    cdef long idx_in, idx_out
    cdef vector[_R2] dest
    dest.resize(src.size)

    shift = shift % src.size

    for idx_in in range(src.size):
        idx_out = (idx_in + shift) % src.size
        dest[idx_out] = src[idx_in]

    return dest

cdef inline void reorient(object[_R2, ndim=1] points):
    # take a list of points where points[0] is the minimum point
    # reorient cw -> ccw or ccw -> cw
    cdef _R2 temp
    cdef int idx = points.size - 1
    cdef _R2 *p_low = &points[1]
    cdef _R2 *p_high = &points[idx]
    while p_high > p_low:
        temp = p_low[0]
        p_low[0] = p_high[0]
        p_high[0] = temp
        p_low += 1
        p_high -= 1


cdef class Polygon(P2Sequence):

    @staticmethod
    def Hull(points not None : Iterable[P2]):
        cdef vector[_R2] point_cloud
        for point in points:
            point_cloud.push_back(py_p2_extract(point))
        cdef Polygon poly = Polygon.__new__(Polygon)
        poly.__data = _jarvis_march_convexhull(
            <_R2[:point_cloud.size()]>point_cloud.data()
        )
        return poly

    @staticmethod
    def from_buffer(object[double, ndim=2] buffer not None):
        cdef Polygon poly = Polygon.__new__(Polygon)
        poly._set_buffer(buffer)
        return poly

    def __init__(Polygon self, object points not None):
        super().__init__(points)
        self._normalize()

    def _normalize(Polygon self):
        if self.__data.size() < 3:
            raise ValueError("Polygon must have at least 3 points.")
        cdef int idx, min_idx
        min_idx = 0
        for idx in range(1, self.__data.size()):
            if r2_cmp_points(self.__data[idx], self.__data[min_idx]) < 0:
                min_idx = idx

        self.__data = roll(self._r2_buffer(), -min_idx)

        if not self._is_ccw():
            reorient(self._r2_buffer())

    cdef Cursor _cursor(Polygon self):
        return Cursor(<_R2*>self.__data.data(), 0, self.__data.size())

    def is_ccw(Polygon self):
        return self._is_ccw()

    cdef bint _is_ccw(Polygon self):
        cdef _LineSegment edge
        cdef Cursor c = self._cursor()
        cdef double accum = 0
        while has_next(c):
            edge = next_edge(c)
            accum += r2_cross(edge.p1, edge.p2)
        return accum > 0

    def points(Polygon self):
        cdef Cursor c = self._cursor()
        while has_next(c):
            yield py_p2_new(next_vertex(c))
        c.idx = 0
        yield py_p2_new(next_vertex(c))

    def edges(Polygon self):
        cdef Cursor c = self._cursor()
        while has_next(c):
            yield py_seg_new(next_edge(c))

    def __str__(self):
        cdef _R2 [::1] data = self._r2_buffer()
        as_str = '\\n'.join('[%f, %f]' % (r['x'], r['y']) for r in data)
        return "Polygon([%s])" % as_str

    def __len__(Polygon self):
        return len(self.__data)

    def centered(Polygon self, P2 center=None):
        cdef _R2 _center = _R2(0,0) if center is None else center.data
        cdef _R2 offset = r2_sub(_center, self._centroid())
        return self._translate(offset)

    def centroid(Polygon self):
        return py_p2_new(self._centroid())

    cdef _R2 _centroid(Polygon self):
        cdef double cx, cy, area, cross
        cdef _LineSegment edge
        cx = 0
        cy = 0
        area = 0

        cdef Cursor coursor = self._cursor()
        while has_next(coursor):
            edge = next_edge(coursor)
            cross = r2_cross(edge.p1, edge.p2)
            cx += (edge.p1.x + edge.p2.x) * cross
            cy += (edge.p1.y + edge.p2.y) * cross
            area += cross
        area *= 3
        return _R2(cx / area, cy / area)


    def area(Polygon self):
        return self._area()

    #@cython.boundscheck(False)
    cdef double _area(Polygon self):
        # shoelace algorithm
        cdef _R2 [::1] points = self._r2_buffer()
        cdef double accum = r2_cross(points[points.size-1], points[0])
        cdef int idx = 0
        for idx in range(points.size-1):
            accum += r2_cross(points[idx], points[idx+1])
        return 0.5 * fabs(accum)

    def perimeter(Polygon self):
        cdef double accum = 0
        cdef Cursor coursor = self._cursor()
        while has_next(coursor):
            accum += ls2_length(next_edge(coursor))
        return accum

    def rotate(Polygon self, double radians, P2 center=None):
        cdef _R2 _center = self._centroid() if center is None else center.data
        cdef _R2 temp
        cdef Polygon poly = Polygon.__new__(Polygon)
        poly.__data.resize(self.__data.size())

        cdef double rsin = sin(radians)
        cdef double rcos = cos(radians)

        cdef int idx
        for idx in range(self.__data.size()):
            temp = r2_sub(self.__data[idx], _center)
            poly.__data[idx].x = temp.x * rcos - temp.y * rsin + _center.x
            poly.__data[idx].y = temp.x * rsin + temp.y * rcos + _center.y

        poly._normalize()
        return poly


    def translate(Polygon self, V2 displacement not None):
        return self._translate(displacement.data)

    cdef Polygon _translate(Polygon self, _R2 displacement):
        cdef Polygon poly = Polygon.__new__(Polygon)
        poly.__data.resize(self.__data.size())

        cdef double x = displacement.x
        cdef double y = displacement.y

        cdef int idx
        for idx in range(self.__data.size()):
            poly.__data[idx] = r2_add(self.__data[idx], displacement)

        # already normalized as long as this one is
        return poly

    def contains_strict(Polygon self, P2 point not None):
        return self._winding_number(point.data) > 0

    def contains(Polygon self, P2 point not None, double rtol=1e-9, double atol=0):
        if self.contains_strict(point):
            return True
        return self.on_perimeter(point, rtol, atol)

    def on_perimeter(Polygon self, P2 point not None, double rtol=1e-9, double atol=0):
        cdef _LineSegment temp
        cdef Cursor c = self._cursor()
        while has_next(c):
            temp = next_edge(c)
            if ls2_contains(temp, point.data, rtol, atol):
                return True
        return False

    cdef double _winding_number(Polygon self, _R2 point):
        cdef _LineSegment temp
        cdef Cursor c = self._cursor()
        cdef winding_number = 0
        while has_next(c):
            temp = next_edge(c)

            if temp.p1.y <= point.y:
                if temp.p2.y > point.y:
                    if r2_ccw(temp.p1, temp.p2, point) > 0:
                        winding_number += 1
            else:
                if temp.p2.y <= point.y:
                    if r2_ccw(temp.p1, temp.p2, point) < 0:
                        winding_number -= 1

        return winding_number


    def approx(Polygon self, Polygon other not None, double rtol=1e-9, double atol=0):
        cdef _R2[::1] this = self._r2_buffer()
        cdef _R2[::1] that = other._r2_buffer()

        if this.size != that.size:
            return False

        cdef int idx
        for idx in range(this.size):
            if not r2_approx(this[idx], that[idx], rtol, atol):
                return False

        return True

    def __eq__(self, other):
        if isinstance(self, Polygon) and isinstance(other, Polygon):
            return self.approx(other)
        return NotImplemented