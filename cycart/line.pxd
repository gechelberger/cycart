cimport cycart.ctypes as c

cdef class Line:
    cdef c.LineData data

cdef class LineSegment:
    cdef c.LineSegmentData data

