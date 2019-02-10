cimport cython

from cycart.native.dtypes cimport _R2
from cycart.native.space cimport r2_ccw

from cpython cimport array
import array

from .pointsort cimport pointsort_heap

cdef inline double ccw(double x1, double y1, double x2, double y2, double x3, double y3):
    return (x2 - x1) * (y3 - y1) - (x3 - x1) * (y2 - y1)

cdef array.array _double_template_array = array.array('d', [])

def jarvis_march_convexhull(object[double, ndim=2] points not None):
    return _jarvis_march_convexhull(points)

@cython.boundscheck(False)
@cython.wraparound(False)
cdef array.array _jarvis_march_convexhull(object[_R2, ndim=1] points):
    print('size', points.size)

    if points.shape[0] < 3:
        raise ValueError()

    pointsort_heap(points)

    cdef int last_idx, current_idx, next_idx
    cdef int hull_size = 0

    cdef array.array hull_arr = array.clone(_double_template_array, 2 * points.size, False)
    cdef _R2 *hull = <_R2*>hull_arr.data.as_voidptr

    last_idx = 0
    while True:
        hull[hull_size] = points[last_idx]
        hull_size += 1

        print('hullsize', hull_size)

        next_idx = (last_idx + 1) % points.size

        for current_idx in range(points.size):
            if r2_ccw(points[last_idx], points[current_idx], points[next_idx]) > 0:
                next_idx = current_idx

        last_idx = next_idx

        if last_idx == 0:
            break

    cdef int resized = array.resize(hull_arr, 2 * hull_size)
    return hull_arr