from cycart.native.dtypes cimport _R2

cdef pointsort_heap(object[_R2, ndim=1] points)

cdef heapify(object[_R2, ndim=1] points, int idx)

cdef swap(object[_R2, ndim=1] points, int idx1, int idx2)