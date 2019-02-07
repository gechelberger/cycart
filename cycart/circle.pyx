cimport cycart.ctypes as c

from cycart.space cimport V2, P2
from cycart.space import V2, P2

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

    def __init__(Circle self, double radius, P2 center=None):
        self.data.radius = radius
        self.data.center = center.data if center else c.C2Data(0, 0)