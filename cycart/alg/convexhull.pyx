cimport cython

cimport numpy as np
import numpy as np

cdef inline double ccw(double x1, double y1, double x2, double y2, double x3, double y3):
    return (x2 - x1) * (y3 - y1) - (x3 - x1) * (y2 - y1)

@cython.boundscheck(False)
@cython.wraparound(False)
def jarvis_march_convexhull(np.ndarray[double, ndim=2] points not None):
    if points.shape[0] < 3:
        raise ValueError()

    cdef int last_idx, current_idx, next_idx
    cdef int hull_size = 0

    # sort points
    #points = points[np.lexsort(np.transpose(points)[::-1])]
    cdef np.ndarray[long, ndim=1] sort_indices = np.lexsort((points[:,1], points[:,0]))
    cdef np.ndarray[double, ndim=2] psorted = points[sort_indices]
    cdef np.ndarray[double, ndim=2] hull = np.empty((points.shape[0], 2), dtype=np.double)

    last_idx = 0
    while True:
        hull[hull_size, 0] = psorted[last_idx, 0]
        hull[hull_size, 1] = psorted[last_idx, 1]
        hull_size += 1

        next_idx = (last_idx + 1) % psorted.shape[0]

        for current_idx in range(psorted.shape[0]):
            if ccw(
                psorted[last_idx,0],
                psorted[last_idx,1],
                psorted[current_idx,0],
                psorted[current_idx,1],
                psorted[next_idx,0],
                psorted[next_idx,1]
            ) > 0:
                next_idx = current_idx


        last_idx = next_idx

        if last_idx == 0:
            break


    return np.resize(hull, (hull_size, 2))