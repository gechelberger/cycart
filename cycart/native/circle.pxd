
from .dtypes cimport _R2, _Circle

from .space cimport (
    r2_sub,
    r2_add,
    r2_dot,
    r2_approx,
)

from .util cimport fapprox

from libc.math cimport pi


"""
Value Functions
"""

cdef inline double c2_constant(const _Circle& circle, const _R2& point):
    cdef _R2 diff = r2_sub(point, circle.center)
    return r2_dot(diff, diff)

cdef inline double c2_area(const _Circle& circle):
    return pi * circle.radius ** 2

cdef inline double c2_circumference(const _Circle& circle):
    return 2 * pi * circle.radius

cdef inline bint c2_on_perimeter(const _Circle& circle, const _R2& point, double rtol=1e-9, atol=0):
    return fapprox(c2_constant(circle, point), circle.radius ** 2, rtol, atol)

cdef inline bint c2_contains(const _Circle& circle, const _R2& point):
    return c2_constant(circle, point) < circle.radius ** 2

cdef inline _Circle c2_translate(const _Circle& circle, const _R2& point):
    return _Circle(r2_add(circle.center, point), circle.radius)

cdef inline bint c2_approx(const _Circle& c1, const _Circle& c2, double rtol=1e-9, atol=0):
    return fapprox(c1.radius, c2.radius, rtol, atol) and r2_approx(c1.center, c2.center, rtol, atol)