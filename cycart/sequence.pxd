from libcpp.vector cimport vector

from cycart.native.dtypes cimport _R2

cdef class P2Sequence:
    cdef vector[_R2] __data

    cdef _R2[::1] _buffer(P2Sequence self)

cdef class P2MutableSequence(P2Sequence):

    cdef _append(P2MutableSequence self, _R2 point)
    cdef _extendbuffer(P2MutableSequence self, object[_R2, ndim=1] points)