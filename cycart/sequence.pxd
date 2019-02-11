from libcpp.vector cimport vector

from cycart.native.dtypes cimport _R2

cdef class P2Sequence:
    cdef vector[_R2] __data

    cdef double[:,::1] _buffer(P2Sequence self)
    cdef _R2[::1] _r2_buffer(P2Sequence self)

    # private method for bypassing __init__
    cdef void _set_buffer(P2Sequence self, object[double, ndim=2] points)


cdef class P2MutableSequence(P2Sequence):

    cdef _append(P2MutableSequence self, _R2 point)
    cdef _extend_buffer(P2MutableSequence self, object[_R2, ndim=1] points)


cdef _R2[::1] r2_buffer(object[double, ndim=2] points)