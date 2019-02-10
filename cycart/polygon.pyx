cimport cython

from cpython cimport array
import array

from libc.math cimport sin, cos, fabs

from cycart.native.dtypes cimport _R2, _LineSegment
from cycart.native.space cimport r2_sub, r2_add, r2_cross
from cycart.native.segment cimport ls2_length

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

cdef class Polygon:

    @staticmethod
    def Hull(points : Iterable[P2]):
        cdef array.array cloud = make_table(points)
        cdef Polygon poly = Polygon.__new__(Polygon)
        poly.__data = _jarvis_march_convexhull(<_R2[:len(cloud)/2]>cloud.data.as_voidptr)

        print('lendata', len(poly.__data))
        return poly

    @staticmethod
    def Of(points : Iterable[P2]):
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

    def __init__(Polygon self, object[double, ndim=2] p2table):
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

        self.__data = roll(<double[:p2table.size]>&p2table[0,0], 2 * min_idx)

    cdef double[:,::1] _buffer(Polygon self):
        cdef int c = len(self.__data)
        return <double[:c/2,:2]>self.__data.data.as_doubles

    cdef _R2[::1] _r2_buffer(Polygon self):
        cdef int c = len(self.__data) // 2
        return <_R2[:c]>self.__data.data.as_voidptr

    cdef Cursor _cursor(Polygon self):
        return Cursor(<_R2*>self.__data.data.as_voidptr, 0, len(self.__data) //2)

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

    """

    def __len__(Polygon self):
        return self.__data.shape[0]

    def area(Polygon self):
        return 0.5*fabs(np.dot(self.xs,np.roll(self.ys,1))-np.dot(self.ys,np.roll(self.xs,1)))

    @cython.boundscheck(False)
    @cython.wraparound(False)
    def perimeter(Polygon self):
        cdef double accum = 0
        cdef Coursor coursor = self._coursor()
        while has_next(coursor):
            accum += ls2_length(next_edge(coursor))
        return accum

    def centroid(Polygon self):
        return P2(0, 0)
        #return py_p2_new(self._centroid())

    #def _centroid(Polygon self):
    #    cdef _R2 centroid
    #    cdef double area = 0, cross
    #    cdef _LineSegment edge
    #    centroid.x = 0
    #    centroid.y = 0
    #    cdef Coursor coursor = self._coursor()
    #    while has_next(coursor):
    #        edge = next_edge(coursor)
    #        cross = r2_cross(edge.p1, edge.p2)
    #        centroid.x += (edge.p1.x + edge.p2.x) * cross
    #        centroid.y += (edge.p1.y + edge.p2.y) * cross
    #        area += cross
    #    area *= 3
    #    centroid.x = centroid.x / area
    #    centroid.y = centroid.y / area
    #    return centroid

    def contains(Polygon self, P2 point):
        pass

    def centered_at(Polygon self, P2 new_center):
        cdef _R2 offset = r2_sub(new_center.data, self.centroid().data)
        cdef Polygon poly = Polygon.__new__(Polygon)
        poly.__data = np.empty((self.__data.shape[0], 2))
        poly.__data[:, 0] = np.add(self.__data[:, 0], offset.x)
        poly.__data[:, 1] = np.add(self.__data[:, 1], offset.y)
        return poly

    def rotate(Polygon self, double radians):
        cdef tempx, tempy
        cdef double rsin = sin(radians)
        cdef double rcos = cos(radians)
        cdef np.ndarray[double, ndim=2] points = np.empty((self.__data.shape[0], 2))

        cdef idx
        for idx in range(self.__data.shape[0]):
            tempx = self.__data[idx, 0]
            tempy = self.__data[idx, 1]
            points[idx, 0] = tempx * rcos - tempy * rsin
            points[idx, 1] = tempx * rsin + tempy * rcos

        return Polygon(points)
"""

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

    @cython.boundscheck(False)
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
            dest[idx] = r2_add(src[idx], displacement.data)

        return poly