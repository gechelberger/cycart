
from cycart.native.dtypes cimport _R2, _LineSegment
from cycart.native.space cimport r2_sub, r2_add

from cpython cimport array
import array


from libc.math cimport sin, cos, fabs


from cycart.native.segment cimport ls2_length

from .space cimport P2, V2, py_p2_new
from .space import P2, V2

from .segment cimport py_seg_new

from typing import Iterable

from .alg.convexhull import jarvis_march_convexhull

"""
cdef bint has_next(Coursor cursor):
    if cursor.idx >= cursor.count:
        return 0
    return 1

cdef _R2 next_vertex(Coursor& c):
    cdef _R2 temp
    temp.x = c.data[2 * c.idx]
    temp.y = c.data[2 * c.idx + 1]
    c.idx += 1
    return temp

cdef _LineSegment next_edge(Coursor& c):
    cdef _LineSegment temp
    cdef int idx2 = (c.idx + 1) % c.count
    temp.p1.x = c.data[2 * c.idx]
    temp.p1.y = c.data[2 * c.idx + 1]
    temp.p2.x = c.data[2 * idx2]
    temp.p2.y = c.data[2 * idx2 + 1]
    c.idx += 1
    return temp
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

    #@staticmethod
    #def Hull(points : Iterable[P2]):
    #    cdef np.ndarray[double, ndim=2] data = make_table(points)
    #    cdef Polygon poly = Polygon.__new__(Polygon)
    #    poly.__data = jarvis_march_convexhull(data)
    #    return poly

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

    cdef points(Polygon self):
        cdef _R2 [::1] data = self._r2_buffer()
        for p in data:
            yield py_p2_new(data)

    """
    def points(Polygon self):
        cdef Coursor coursor = self._coursor()
        while has_next(coursor):
            yield py_p2_new(next_vertex(coursor))

    def edges(Polygon self):
        cdef Coursor coursor = self._coursor()
        while has_next(coursor):
            yield py_seg_new(next_edge(coursor))

    cdef Coursor _coursor(Polygon self):
        return Coursor(<double*>self.__data.data, 0, self.__data.shape[0])

    cdef np.ndarray[double, ndim=2] _buffer(Polygon self):
        return self.__data

    #def edges(Polygon self):
    #    cdef Coursor coursor = self._coursor()
    #    while has_next(coursor):
    #        yield py_seg_new(next_edge(coursor))

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

    def translate(Polygon self, V2 displacement):
        cdef Polygon poly = Polygon.__new__(Polygon)
        poly.__data = np.empty((self.__data.shape[0], 2))
        poly.__data[:, 0] = np.add(self.__data[:, 0], displacement.data.x)
        poly.__data[:, 1] = np.add(self.__data[:, 1], displacement.data.y)
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

    def translate(Polygon self, V2 displacement not None):
        cdef _R2[::1] src = self._r2_buffer()
        cdef Polygon poly = Polygon.__new__(Polygon)
        poly.__data = array.clone(_double_template_array, 2 * src.size, False)
        cdef _R2[::1] dest = poly._r2_buffer()

        cdef double x = displacement.data.x
        cdef double y = displacement.data.y

        cdef int idx
        for idx in range(src.size):
            dest[idx] = r2_add(src[idx], displacement.data)

        return poly