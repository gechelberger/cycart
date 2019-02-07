from libc.math cimport cos, sin, acos, sqrt

from .dtypes cimport _R2

from .util cimport fapprox


# c2 value functions

cdef inline _R2 r2_polar(double radius, double radians):
    return _R2(radius * cos(radians), radius * sin(radians))

cdef inline _R2 r2_neg(const _R2& value):
    return _R2(-value.x, -value.y)

cdef inline _R2 r2_add(const _R2& lhs, const _R2& rhs):
    return _R2(lhs.x + rhs.x, lhs.y + rhs.y)

cdef inline _R2 r2_sub(const _R2& lhs, const _R2& rhs):
    return _R2(lhs.x - rhs.x, lhs.y - rhs.y)

cdef inline _R2 r2_mul(const _R2& vec, double scalar):
    return _R2(vec.x * scalar, vec.y * scalar)

cdef inline _R2 r2_mul2(const _R2& lhs, const _R2& rhs):
    return _R2(lhs.x * rhs.x, lhs.y * rhs.y)

cdef inline _R2 r2_rotate(const _R2& vec, double radians):
    cdef double rad_cos = cos(radians)
    cdef double rad_sin = sin(radians)
    return _R2(
        vec.x * rad_cos - vec.y * rad_sin,
        vec.x * rad_sin + vec.y * rad_cos
    )

cdef inline _R2 r2_rotate_around(const _R2& point, const _R2& center, double radians):
    return r2_add(center, r2_rotate(r2_sub(point, center), radians))

cdef inline double r2_cross(const _R2& lhs, const _R2& rhs):
    return lhs.x * rhs.y - lhs.y * rhs.x

cdef inline double r2_dot(const _R2& lhs, const _R2& rhs):
    return lhs.x * rhs.x + lhs.y * rhs.y

cdef inline double r2_magnitude(const _R2& vector):
    return sqrt(r2_dot(vector, vector))

cdef inline double r2_distance(const _R2& p1, const _R2& p2):
    return r2_magnitude(r2_sub(p1, p2))

cdef inline double r2_ccw(const _R2& p1, const _R2& p2, const _R2& p3):
    return (p2.x - p1.x) * (p3.y - p1.y) - (p3.x - p1.x) * (p2.y - p1.y)

cdef inline bint r2_parallel(const _R2& lhs, const _R2& rhs, double rtol=1e-9, double atol=0):
    return fapprox(r2_cross(lhs, rhs), 0, rtol, atol)

cdef inline bint r2_orthogonal(const _R2& lhs, const _R2& rhs, double rtol=1e-9, double atol=0):
    return fapprox(r2_dot(lhs, rhs), 0, rtol, atol)

cdef inline bint r2_approx(const _R2& lhs, const _R2& rhs, double rtol=1e-9, double atol=0):
    return fapprox(lhs.x, rhs.x, rtol, atol) and fapprox(lhs.y, rhs.y, rtol, atol)

cdef inline int r2_cmp_points(const _R2& lhs, const _R2& rhs):
    if lhs.x > rhs.x:
        return 1
    if lhs.x < rhs.x:
        return -1
    if lhs.y > rhs.y:
        return 1
    if lhs.y < rhs.y:
        return -1
    return 0

# c2 ref out functions

cdef inline bint r2_ref_div(_R2& out, const _R2& vector, double scalar):
    if scalar == 0:
        return 0
    out.x = vector.x / scalar
    out.y = vector.y / scalar
    return 1

cdef inline bint r2_ref_div2(_R2& out, const _R2& lhs, const _R2& rhs):
    if rhs.x == 0 or rhs.y == 0:
        return 0
    out.x = lhs.x / rhs.x
    out.y = lhs.y / rhs.y
    return 1

cdef inline bint r2_ref_unit(_R2& out, const _R2& vector):
    return r2_ref_div(out, vector, r2_magnitude(vector))

cdef inline bint r2_ref_vector_angle(double& radians, const _R2& v1, const _R2& v2):
    cdef double divisor = r2_magnitude(v1) * r2_magnitude(v2)
    if divisor == 0:
        return 0
    (&radians)[0] = acos(r2_dot(v1, v2) / divisor)
    return 1

cdef inline bint r2_ref_point_angle(double& radians, const _R2& p1, const _R2& p2, const _R2& p3):
    return r2_ref_vector_angle(radians, r2_sub(p1, p2), r2_sub(p3, p2))
