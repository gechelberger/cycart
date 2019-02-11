from libcpp.vector cimport vector
from cycart.native.dtypes cimport _R2

cdef vector[_R2] _jarvis_march_convexhull(object[_R2, ndim=1] points)