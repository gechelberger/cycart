from cycart.native.dtypes cimport _LineSegment

cdef class LineSegment:
    cdef _LineSegment data

cdef inline LineSegment py_seg_new(_LineSegment segment):
    cdef LineSegment py_seg = LineSegment.__new__(LineSegment)
    py_seg.data = segment
    return py_seg