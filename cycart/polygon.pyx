cimport cython

from cpython cimport array
import array

from libc.math cimport sin, cos, fabs

from cycart.native.dtypes cimport _R2, _LineSegment
from cycart.native.space cimport r2_sub, r2_add, r2_cross, r2_approx, r2_ccw
from cycart.native.segment cimport ls2_length, ls2_contains

from .space cimport P2, V2, py_p2_new
from .space import P2, V2
from .segment cimport py_seg_new

from typing import Iterable

from .alg.convexhull cimport _jarvis_march_convexhull

"""
"""

cdef array.array _double_template_array = array.array('d', [])

cdef array.array roll(double[::1] src, int shift):
    cdef int idx_in, idx_out
    cdef array.array dest = array.clone(_double_template_array, src.size, False)

    shift = shift % src.size

    for idx_in in range(src.size):
        idx_out = (idx_in + shift) % src.size
        dest[idx_out] = src[idx_in]

    return dest

cdef array.array make_table(points):
    cdef array.array dest = array.array('d', [])
    for point in points:
        dest.append(point.x)
        dest.append(point.y)
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


cdef class Polygon:

    @staticmethod
    def Hull(points not None : Iterable[P2]):
        cdef array.array cloud = make_table(points)
        cdef Polygon poly = Polygon.__new__(Polygon)
        poly.__data = _jarvis_march_convexhull(<_R2[:len(cloud)/2]>cloud.data.as_voidptr)

        print('lendata', len(poly.__data))
        return poly

    @staticmethod
    def Of(points not None : Iterable[P2]):
        cdef array.array data = make_table(points)
        cdef double[::1] dview = data
        return Polygon(<double[:dview.size//2,:2]>&dview[0])

    @property
    def xs(self):
        return array.array('d', self._buffer()[:,0])

    @property
    def ys(self):
        return array.array('d', self._buffer()[:,1])
        #return self._buffer()[:, 1]
        #return np.array(self.__data[:, 1], dtype=np.double)

    def __init__(Polygon self, object[double, ndim=2] p2table not None):
        if p2table.shape[1] != 2:
            raise ValueError("Expected 2 columns for X and Y")
        if p2table.shape[0] < 3:
            raise ValueError("Polygon must have at least 3 points.")

        cdef int idx, min_idx
        min_idx = 0
        for idx in range(1, p2table.shape[0]):
            if p2table[idx, 0] < p2table[min_idx,0]:
                min_idx = idx
            elif p2table[idx, 0] == p2table[min_idx,0]:
                if p2table[idx,1] < p2table[min_idx,1]:
                    min_idx = idx

        self.__data = roll(<double[:p2table.size]>&p2table[0,0], -2 * min_idx)

        if not self._is_ccw():
            reorient(self._r2_buffer())


    cdef double[:,::1] _buffer(Polygon self):
        cdef int c = len(self.__data)
        return <double[:c/2,:2]>self.__data.data.as_doubles

    cdef _R2[::1] _r2_buffer(Polygon self):
        cdef int c = len(self.__data) // 2
        return <_R2[:c]>self.__data.data.as_voidptr

    cdef Cursor _cursor(Polygon self):
        return Cursor(<_R2*>self.__data.data.as_voidptr, 0, len(self.__data) //2)

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
        cdef _R2 [::1] src = self._r2_buffer()
        cdef array.array data = array.clone(_double_template_array, 2 * src.size, False)
        cdef double [:,::1] dest = <double[:src.size,:2]>data.data.as_voidptr

        cdef double rsin = sin(radians)
        cdef double rcos = cos(radians)

        cdef int idx
        for idx in range(src.size):
            temp = r2_sub(src[idx], _center)
            dest[idx, 0] = temp.x * rcos - temp.y * rsin + _center.x
            dest[idx, 1] = temp.x * rsin + temp.y * rcos + _center.y

        return Polygon(dest)


    def translate(Polygon self, V2 displacement not None):
        return self._translate(displacement.data)

    cdef Polygon _translate(Polygon self, _R2 displacement):
        cdef _R2[::1] src = self._r2_buffer()
        cdef Polygon poly = Polygon.__new__(Polygon)
        poly.__data = array.clone(_double_template_array, 2 * src.size, False)
        cdef _R2[::1] dest = poly._r2_buffer()

        cdef double x = displacement.x
        cdef double y = displacement.y

        cdef int idx
        for idx in range(src.size):
            dest[idx] = r2_add(src[idx], displacement)

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