#cimport numpy as np
#import numpy as np

from cpython cimport array

from cycart.native.dtypes cimport _R2

cdef class Polygon:
    #cdef double[:,::1] _points
    cdef array.array __data


    cdef double[:,::1] _buffer(Polygon self)

    cdef _R2[::1] _r2_buffer(Polygon self)

    #cdef np.ndarray __data

    #cdef np.ndarray[double, ndim=2] _buffer(Polygon self)

    #cdef Coursor _coursor(Polygon self)

    #cdef _R2 _centroid(Polygon self)

"""
cdef struct Coursor:
    double* data
    long idx
    long count
"""