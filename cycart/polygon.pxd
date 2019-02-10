#cimport numpy as np
#import numpy as np

from cpython cimport array

from cycart.native.dtypes cimport _R2, _LineSegment

cdef class Polygon:
    cdef array.array __data

    cdef double[:,::1] _buffer(Polygon self)

    cdef _R2[::1] _r2_buffer(Polygon self)

    cdef Cursor _cursor(Polygon self)

    cdef double _area(Polygon self)
    cdef _R2 _centroid(Polygon self)
    cdef Polygon _translate(Polygon self, _R2 displacement)
    cdef bint _is_ccw(Polygon self)
    cdef double _winding_number(Polygon self, _R2 point)



cdef struct Cursor:
    _R2* data
    long idx
    long count

cdef inline bint has_next(Cursor c):
    if c.idx >= c.count:
        return 0
    return 1

cdef inline _R2 next_vertex(Cursor& c):
    cdef _R2 temp = c.data[c.idx]
    c.idx += 1
    return temp

cdef inline _LineSegment next_edge(Cursor& c):
    cdef _LineSegment temp
    cdef int idx2 = (c.idx + 1) % c.count
    temp.p1 = c.data[c.idx]
    temp.p2 = c.data[idx2]
    c.idx += 1
    return temp