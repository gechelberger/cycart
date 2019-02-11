cimport cython

from libcpp.vector cimport vector

from cycart.native.dtypes cimport _R2
from cycart.native.space cimport r2_ccw

from .pointsort cimport pointsort_heap

cdef inline double ccw(double x1, double y1, double x2, double y2, double x3, double y3):
    return (x2 - x1) * (y3 - y1) - (x3 - x1) * (y2 - y1)

def jarvis_march_convexhull(object[double, ndim=2] points not None):
    return _jarvis_march_convexhull(points)

@cython.boundscheck(False)
@cython.wraparound(False)
cdef vector[_R2] _jarvis_march_convexhull(object[_R2, ndim=1] points):
    cdef vector[_R2] hull

    if points.shape[0] < 3:
        return hull

    pointsort_heap(points)

    cdef int last_idx, current_idx, next_idx


    last_idx = 0
    while True:
        hull.push_back(points[last_idx])


        next_idx = (last_idx + 1) % points.size

        for current_idx in range(points.size):
            if r2_ccw(points[last_idx], points[current_idx], points[next_idx]) > 0:
                next_idx = current_idx

        last_idx = next_idx

        if last_idx == 0:
            break

    return hull