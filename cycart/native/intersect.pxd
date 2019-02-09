from libcpp.vector cimport vector

from libc.math cimport sqrt, fabs

from .dtypes cimport _R2, _Line, _LineSegment, _Circle

from .space cimport (
    r2_neg,
    r2_add,
    r2_sub,
    r2_magnitude,
    r2_cross,
    r2_dot,
    r2_mul,
    r2_ref_unit,
    r2_parallel,
)

from .line cimport (
    l2_ref_by_points,
    l2_approx,
    l2_ref_translate,
    l2_ref_f_of_x,
    l2_ref_f_of_y,
)

from .segment cimport ls2_contains, ls2_vector, ls2_approx, ls2_overlaps

from .does_intersect cimport c2_c2_does_intersect, IRES, ERROR, NO, YES


cdef inline bint l2_l2_intersect_set(vector[_R2]& out, const _Line& l1, const _Line& l2):
    if l2_approx(l1, l2):
        return False
    cdef _R2 candidate
    if l2_l2_intersect(candidate, l1, l2):
        out.push_back(candidate)
    return True

cdef inline bint c2_c2_intersect_set(vector[_R2]& out, const _Circle& c1, const _Circle& c2):
    cdef IRES check = c2_c2_does_intersect(c1, c2)
    if check == ERROR:
        return False
    if check == NO:
        return True

    cdef _R2 cvec = r2_sub(c2.center, c1.center)
    cdef double cdist = r2_magnitude(cvec)

    cdef double apothem = (c1.radius ** 2 - c2.radius ** 2 + cdist ** 2) / (2 * cdist)

    if not r2_ref_unit(cvec, cvec):
        return False

    cvec = r2_add(c1.center, r2_mul(cvec, apothem))
    if apothem == c1.radius:
        out.push_back(cvec)
        return True

    cdef double h = sqrt(c1.radius ** 2 - apothem ** 2)
    cdef _R2 offset
    offset.x = c2.center.y - c1.center.y
    offset.y = c1.center.x - c2.center.x
    offset = r2_mul(offset, h / cdist)

    out.push_back(r2_add(cvec, offset))
    out.push_back(r2_sub(cvec, offset))
    return True

cdef inline bint ls2_ls2_intersect_set(vector[_R2]& out, const _LineSegment& ls1, const _LineSegment& ls2):
    if ls2_overlaps(ls1, ls2):
        return False

    #if ls2_overlap(ls1, ls2) > 0:
    #    return False

    cdef _R2 candidate
    if ls2_ls2_intersect(candidate, ls1, ls2):
        out.push_back(candidate)

    return True

cdef inline bint ls2_c2_intersect_set(vector[_R2]& out, const _LineSegment& seg, const _Circle circle):
    cdef vector[_R2] collect
    cdef _Line line
    if not l2_ref_by_points(line, seg.p1, seg.p2):
        return False

    if not l2_c2_intersect_set(collect, line, circle):
        return False

    #cdef _R2 temp
    for point in collect:
        #temp.x, temp.y = point
        if ls2_contains(seg, point):
            out.push_back(point)

    return True

cdef inline bint ls2_l2_intersect_set(vector[_R2]& out, const _LineSegment& seg, const _Line line):
    cdef _Line seg_line
    if not l2_ref_by_points(seg_line, seg.p1, seg.p2):
        return False

    if l2_approx(line, seg_line):
        return False

    cdef _R2 candidate
    if l2_l2_intersect(candidate, seg_line, line):
        if ls2_contains(seg, candidate):
            out.push_back(candidate)
    return True

cdef inline bint l2_c2_intersect_set(vector[_R2]& out, const _Line& line, const _Circle circle):
    cdef _Line line00

    if not l2_ref_translate(line00, line, r2_neg(circle.center)):
        return False

    cdef _R2 p1, p2
    if l2_ref_f_of_x(p1.y, line00, 0) and l2_ref_f_of_x(p2.y, line00, 1):
        p1.x = 0
        p2.x = 1
    elif l2_ref_f_of_y(p1.x, line00, 0) and l2_ref_f_of_y(p2.x, line00, 1):
        p1.y = 0
        p2.y = 1
    else:
        return False

    cdef _R2 dv = r2_sub(p2, p1)
    cdef double dr2 = r2_magnitude(dv) ** 2
    cdef double determinant = r2_cross(p1, p2)
    cdef descriminant = circle.radius ** 2 * dr2 - determinant ** 2
    if descriminant < 0:
        return True

    cdef _R2 central
    central.x = determinant * dv.y / dr2
    central.y = determinant * dv.x / dr2
    central = r2_add(circle.center, central)
    #cdef _R2 central = r2_add(circle.center, _R2(
    #    determinant * dv.y / dr2,
    #    determinant * dv.x / dr2
    #))

    if descriminant == 0:
        out.push_back(central)
        return True

    cdef double sqrt_desc = sqrt(descriminant)
    cdef double sign_y = -1 if dv.y < 0 else 1
    cdef _R2 offset
    offset.x = sign_y * dv.x * sqrt_desc / dr2
    offset.y = fabs(dv.y) * sqrt_desc / dr2


    out.push_back(r2_add(central, offset))
    out.push_back(r2_sub(central, offset))
    return True




cdef inline bint l2_l2_intersect(_R2& out, const _Line& l1, const _Line& l2):
    cdef det = l1.a * l2.b - l1.b * l2.a
    if det == 0:
        return False
    out.x = (l2.b * l1.c - l1.b * l2.c) / det
    out.y = (l1.a * l2.c - l2.a * l1.c) / det
    return True

cdef inline bint ls2_ls2_intersect(_R2& out, const _LineSegment ls1, const _LineSegment& ls2):
    cdef _R2 v1 = ls2_vector(ls1)
    cdef _R2 v2 = ls2_vector(ls2)
    cdef _R2 perp1 = _R2(-v1.y, v1.x)
    cdef _R2 diff = r2_sub(ls1.p1, ls2.p1)
    cdef double divisor = r2_dot(v2, perp1)
    if divisor == 0:
        return False

    cdef double t = r2_dot(diff, perp1) / divisor
    if 0 <= t <= 1:
        (&out)[0] = r2_add(ls2.p1, r2_mul(v2, t))
        return True
    return False