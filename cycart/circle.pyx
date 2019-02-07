from cycart.native.dtypes cimport _R2

from cycart.native.circle cimport (
    c2_on_perimeter,
    c2_contains,
    c2_area,
    c2_circumference,
    c2_translate,
    c2_approx
)


from cycart.space cimport V2, P2, py_p2_new
from cycart.space import V2, P2

zero = V2(0, 0)

cdef class Circle:

    @property
    def center(self):
        return py_p2_new(self.data.center)

    @property
    def radius(self):
        return self.data.radius

    @property
    def diameter(self):
        return self.data.radius * 2

    @property
    def circumference(self):
        return c2_circumference(self.data)

    @property
    def area(self):
        return c2_area(self.data)

    def __init__(Circle self, double radius, P2 center=None):
        self.data.radius = radius
        self.data.center = _R2(0, 0) if center is None else center.data

    def translate(Circle self, V2 vector not None):
        return py_circle_new(c2_translate(self.data, vector.data))

    def on_circumference(Circle self, P2 point not None, double rtol=1e-9, atol=0):
        return c2_on_perimeter(self.data, point.data, rtol, atol)

    def approx(Circle self, Circle other not None, double rtol=1e-9, atol=0):
        return c2_approx(self.data, other.data, rtol, atol)

    def contains(Circle self, P2 point not None, double rtol=1e-9, atol=0):
        return c2_contains(self.data, point.data) or c2_on_perimeter(self.data, point.data, rtol, atol)

    def __contains__(Circle self, P2 point not None):
        return self.contains(point)

    #def does_intersect(Circle self, Circle other not None):
    #    if self.approx(other):
    #        raise ValueError("Circles are identical")
    #    return c.circle_circle_does_intersect(self.data, other.data)

    # def intersect(Circle self, Circle other not None):
    #     if not self.does_intersect(other):
    #         return set()
    #
    #     cdef double r1 = self.data.radius
    #     cdef double r2 = other.data.radius
    #     cdef c.C2Data c1 = self.data.center
    #     cdef c.C2Data c2 = other.data.center
    #
    #     cdef c.C2Data center_vector
    #     if not c.c2_sub_vector(center_vector, c2, c1):
    #         raise RuntimeError("unknown error")
    #
    #     cdef center_dist = c.c2_magnitude(center_vector)
    #
    #     cdef apothem = (r1 ** 2 - r2 ** 2 + center_dist ** 2) / (2 * center_dist)
    #
    #     cdef P2 ret1 = P2.__new__(P2)
    #     if not c.c2_unit_vector(ret1.data, center_vector):
    #         raise RuntimeError("unknown error")
    #     if not c.c2_mul_scalar(ret1.data, ret1.data, apothem):
    #         raise RuntimeError("unknown error")
    #     if not c.c2_add_vector(ret1.data, ret1.data, c1):
    #         raise RuntimeError("unknown error")
    #
    #     if c.fapprox(r1, apothem):
    #         return { ret1 }
    #
    #     cdef double h = sqrt(r1 ** 2 - apothem ** 2)
    #     cdef c.C2Data offset = c.C2Data(
    #         h / center_dist * (c2.y - c1.y),
    #         h / center_dist * (c1.x - c2.x)
    #     )
    #     cdef P2 ret2 = P2.__new__(P2)
    #     if not c.c2_sub_vector(ret2.data, ret1.data, offset):
    #         raise RuntimeError("unknown error")
    #     if not c.c2_add_vector(ret1.data, ret1.data, offset):
    #         raise RuntimeError("unknown error")
    #
    #     return { ret1, ret2 }
