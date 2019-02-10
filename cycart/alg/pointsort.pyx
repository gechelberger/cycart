from libcpp.vector cimport vector

from cycart.native.dtypes cimport _R2

from cycart.native.space cimport r2_cmp_points

from cycart.space cimport P2, py_p2_new

def pointsort(points):
    cdef vector[_R2] vec
    for p in points:
        vec.push_back(get_r2(p))
    pointsort_heap(<_R2[:vec.size()]>&vec[0])
    return tuple(py_p2_new(r) for r in vec)

cdef inline _R2 get_r2(P2 inst):
    return inst.data

def pointsort_table(object[double, ndim=2] points):
    cdef void* pointer = <void*>&points[0,0]
    pointsort_heap(<_R2[:points.size//2]>pointer)
    return points

cdef pointsort_heap(object[_R2, ndim=1] points):
    cdef int idx = points.size / 2 - 1

    while idx >= 0:
        heapify(points, idx)
        idx -= 1

    idx = points.size - 1
    while idx >= 0:
        swap(points, 0, idx)
        heapify(points[0:idx], 0)
        idx -= 1

cdef heapify(object[_R2, ndim=1] points, int idx):
    cdef int largest = idx
    cdef int left = 2 * idx + 1
    cdef int right = 2 * idx + 2

    if left < points.size and r2_cmp_points(points[left], points[largest]) > 0:
        largest = left

    if right < points.size and r2_cmp_points(points[right], points[largest]) > 0:
        largest = right

    if largest != idx:
        swap(points, idx, largest)
        heapify(points, largest)

cdef swap(object[_R2, ndim=1] points, int idx1, int idx2):
    cdef _R2 temp = points[idx1]
    points[idx1] = points[idx2]
    points[idx2] = temp
