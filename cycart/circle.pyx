cimport cycart.ctypes as c

from cycart.vector cimport V2
from cycart.vector import V2

zero = V2(0, 0)

cdef class Circle:

    @property
    def center(self):
        cdef V2 ret = V2.__new__(V2)
        ret.data = self.data.center
        return ret

    @property
    def radius(self):
        return self.data.radius

    @property
    def diameter(self):
        return self.data.radius * 2

    def __init__(Circle self, double radius, center)