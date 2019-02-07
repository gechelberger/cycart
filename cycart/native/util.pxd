from libc.math cimport fmax, fabs

cdef inline bint fapprox(double a, double b, double rtol=1e-9, atol=0):
    cdef epsilon
    epsilon = fmax(atol, rtol * fmax(1, fmax(a, b)))
    return fabs(a - b) <= fabs(epsilon)