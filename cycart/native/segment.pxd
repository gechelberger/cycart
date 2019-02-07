from .dtypes cimport _R2, _LineSegment

from .space cimport (
    r2_cmp_points,
    r2_magnitude,
    r2_add,
    r2_sub,
    r2_dot,
    r2_parallel,
    r2_approx,
    r2_ref_div,
    r2_rotate_around,
    r2_ccw
)

from .util cimport fapprox


"""
Value Functions
"""

cdef inline _LineSegment ls2_normalized(const _LineSegment& segment):
    if r2_cmp_points(segment.p1, segment.p2) <= 0:
        return segment
    return _LineSegment(segment.p2, segment.p1)

cdef inline double ls2_length(const _LineSegment& segment):
    return r2_magnitude(ls2_vector(segment))

cdef inline bint ls2_contains(const _LineSegment& segment, const _R2& point, double rtol=1e-9, atol=0):
    cdef _R2 ref_vector = ls2_vector(segment)
    cdef _R2 test_vector = r2_sub(point, segment.p1)

    if not r2_parallel(ref_vector, test_vector, rtol, atol):
        return 0
    if 0 <= r2_dot(ref_vector, test_vector) <= r2_dot(ref_vector, ref_vector):
        return 1
    if r2_approx(segment.p1, point, rtol, atol):
        return 1
    if r2_approx(segment.p2, point, rtol, atol):
        return 1
    return 0

cdef inline bint ls2_approx(const _LineSegment& lhs, const _LineSegment& rhs, double rtol=1e-9, atol=0):
    cdef _LineSegment norm1 = ls2_normalized(lhs)
    cdef _LineSegment norm2 = ls2_normalized(lhs)
    return r2_approx(norm1.p1, norm2.p1, rtol, atol) and r2_approx(norm1.p2, norm2.p2, rtol, atol)


cdef inline _R2 ls2_vector(const _LineSegment& segment):
    return r2_sub(segment.p2, segment.p1)

cdef inline _LineSegment ls2_translate(const _LineSegment& segment, const _R2 vector):
    return _LineSegment(r2_add(segment.p1, vector), r2_add(segment.p2, vector))

cdef inline _R2 ls2_center(const _LineSegment& segment):
    cdef _R2 vector = ls2_vector(segment)
    if not r2_ref_div(vector, vector, 2.0):
        pass #oops
    return r2_add(segment.p1, vector)


cdef inline _LineSegment ls2_rotate(const _LineSegment& segment, const _R2 center, double radians):
    return _LineSegment(
        r2_rotate_around(segment.p1, center, radians),
        r2_rotate_around(segment.p2, center, radians)
    )