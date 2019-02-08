from libc.math cimport fabs

from .dtypes cimport _R2, _Circle, _Line, _LineSegment

from .space cimport r2_distance, r2_ccw, r2_cmp_points, r2_sub, r2_dot
from .circle cimport c2_approx, c2_contains
from .line cimport l2_approx, l2_point_on_side, l2_constant, l2_ref_by_points, l2_closest_point
from .segment cimport ls2_approx, ls2_normalized

cdef enum IRES:
    ERROR = -1
    NO = 0
    YES = 1

cdef inline IRES c2_c2_does_intersect(const _Circle& c1, const _Circle& c2):
    if c2_approx(c1, c2):
        return ERROR

    cdef double distance = r2_distance(c1.center, c2.center)
    if distance > c1.radius + c2.radius:
        return NO
    if distance < fabs(c1.radius - c2.radius):
        return NO
    return YES

cdef inline IRES l2_l2_does_intersect(const _Line& l1, const _Line l2):
    if l2_approx(l1, l2):
        return ERROR

    cdef det = l1.a * l2.b - l1.b * l2.a
    return det != 0

cdef inline IRES ls2_ls2_does_intersect(const _LineSegment& ls1, const _LineSegment& ls2):
    if ls2_approx(ls1, ls2):
        return ERROR

    cdef double ccw1, ccw2
    ccw1 = r2_ccw(ls1.p1, ls1.p2, ls2.p1)
    ccw2 = r2_ccw(ls1.p1, ls1.p2, ls2.p2)
    if ccw1 * ccw2 > 0:
        return NO
    ccw1 = r2_ccw(ls2.p1, ls2.p2, ls1.p1)
    ccw2 = r2_ccw(ls2.p1, ls2.p2, ls1.p2)
    if ccw1 * ccw2 > 0:
        return NO
    return YES

cdef inline IRES ls2_c2_does_intersect(const _LineSegment& seg, const _Circle& circle):
    cdef _Line line
    if not l2_ref_by_points(line, seg.p1, seg.p2):
        return ERROR

    cdef _R2 closest = l2_closest_point(line, circle.center)
    cdef _LineSegment norm = ls2_normalized(seg)

    if r2_cmp_points(closest, norm.p2) > 0:
        closest = norm.p2
    elif r2_cmp_points(closest, norm.p1) < 0:
        closest = norm.p1

    cdef _R2 dist = r2_sub(circle.center, closest)
    if r2_dot(dist, dist) > circle.radius ** 2:
        return NO

    if c2_contains(circle, norm.p1) and c2_contains(circle, norm.p2):
        return NO

    return YES

cdef inline IRES ls2_l2_does_intersect(const _LineSegment& seg, const _Line& line):
    cdef int s1 = l2_point_on_side(line, seg.p1)
    cdef int s2 = l2_point_on_side(line, seg.p2)
    if s1 == s2 == 0:
        return ERROR
    if s1 == s2:
        return NO
    return YES

cdef inline IRES l2_c2_does_intersect(const _Line& line, const _Circle& circle):
    cdef lconst = fabs(l2_constant(line, circle.center) - line.c)
    cdef dist2 = lconst ** 2 / (line.a ** 2 + line.b ** 2)
    return dist2 <= circle.radius ** 2

#todo: polygon