from .dtypes cimport _R2, _Line
from .space cimport r2_ref_unit
from .util cimport fapprox


cdef inline int l2_point_on_side(const _Line& line, const _R2& point):
    cdef double reference
    if l2_ref_f_of_x(reference, line, point.x):
        if point.y > reference:
            return 1
        if point.y < reference:
            return -1
        return 0
    elif l2_ref_f_of_y(reference, line, point.y):
        if point.x > reference:
            return 1
        if point.x < reference:
            return -1
        return 0
    return -2 # should never happen for non-degenerate line

cdef inline double l2_constant(const _Line& line, const _R2& point):
    return line.a * point.x + line.b * point.y

cdef inline _R2 l2_normal(const _Line& line):
    cdef _R2 norm = _R2(line.a, line.b)
    r2_ref_unit(norm, norm)
    return norm


cdef inline bint l2_approx(const _Line& l1, const _Line& l2, rtol=1e-9, atol=0):
    return fapprox(l1.a, l2.a, rtol, atol) and fapprox(l1.b, l2.b, rtol, atol) and fapprox(l1.c, l2.c, rtol, atol)


cdef inline _R2 l2_closest_point(const _Line& line, const _R2& point):
    cdef _R2 closest
    cdef _Line perp
    if not l2_ref_perpendicular(perp, line, point):
        closest = point
    else:
        l2_l2_intersect(closest, line, perp)
    return closest


cdef inline bint l2_contains_point(const _Line& line, const _R2& point, double rtol=1e-9, double atol=0):
    return fapprox(l2_constant(line, point), line.c, rtol, atol)


"""

"""

cdef inline bint l2_ref_normalize(_Line& out):
    if out.a == 0 and out.b == 0:
        return 0

    cdef double divisor = 0
    if out.c:
        divisor = out.c
    elif out.b:
        divisor = out.b
    elif out.a:
        divisor = out.a

    out.c /= divisor
    out.b /= divisor
    out.a /= divisor
    return 1

cdef inline bint l2_ref_by_points(_Line& out, const _R2& p1, const _R2& p2):
    out.a = p1.y - p2.y # -dy
    out.b = p2.x - p1.x # dx
    out.c = out.b * p1.y + out.a * p1.x
    return l2_ref_normalize(out)

cdef inline bint l2_ref_translate(_Line& out, const _Line& line, const _R2& vec):
    out.a = line.a * (line.c + line.b * vec.y)
    out.b = line.b * (line.c + line.a * vec.x)
    out.c = line.c ** 2
    out.c += line.a * line.c * vec.x
    out.c += line.b * line.c * vec.y
    out.c += line.a * line.b * vec.x * vec.y
    return l2_ref_normalize(out)

cdef inline bint l2_ref_perpendicular(_Line& out, const _Line& line, const _R2& point):
    #todo: check contains
    out.a = -line.b
    out.b = line.a
    out.c = line.a * point.y - line.b * point.x
    return l2_ref_normalize(out)

cdef inline bint l2_ref_parallel(_Line& out, const _Line& line, const _R2& point):
    out.a = line.a
    out.b = line.b
    out.c = line.a * point.x + line.b * point.y
    return l2_ref_normalize(out)



cdef inline bint l2_l2_intersect(_R2& out, const _Line& l1, const _Line& l2):
    cdef det = l1.a * l2.b - l1.b * l2.a
    if det == 0:
        return 0
    out.x = (l2.b * l1.c - l1.b * l2.c) / det
    out.y = (l1.a * l2.c - l2.a * l1.c) / det
    return 1

cdef inline bint l2_ref_f_of_y(double& out, const _Line& line, double y):
    if line.a == 0:
        return 0
    (&out)[0] = (line.c - line.b * y) / line.a
    return 1

cdef inline bint l2_ref_f_of_x(double& out, const _Line& line, double x):
    if line.b == 0:
        return 0
    (&out)[0] = (line.c - line.a * x) / line.b
    return 1