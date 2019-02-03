cimport cython
cimport cycart.ctypes as c


"""

"""

def _add(lhs not None, rhs not None):
    lhs_type = type(lhs)
    rhs_type = type(rhs)
    if lhs_type is V2 and rhs_type is V2:
        return v2_v2_add(lhs, rhs)
    if lhs_type is P2 and rhs_type is V2:
        return p2_v2_add(lhs, rhs)
    if lhs_type is V2 and rhs_type is P2:
        return p2_v2_add(rhs, lhs)
    raise TypeError("Expected Types: V2 or P2. Got: %s, %s" % (lhs_type.__name__, rhs_type.__name__))


def _sub(lhs not None, rhs not None):
    lhs_type = type(lhs)
    rhs_type = type(rhs)
    if lhs_type is V2 and rhs_type is V2:
        return v2_v2_sub(lhs, rhs)
    if lhs_type is P2 and rhs_type is V2:
        return p2_v2_sub(lhs, rhs)
    if lhs_type is V2 and rhs_type is P2:
        return v2_p2_sub(lhs, rhs)
    raise TypeError()

"""

"""

cdef class V2:

    @property
    def x(self):
        return self.data.x

    @property
    def y(self):
        return self.data.y

    def __init__(V2 self, double x, double y):
        self.data.x = x
        self.data.y = y

    cpdef P2 point(V2 self):
        cdef P2 ret = P2.__new__(P2)
        ret.data = self.data
        return ret

    """
    Arithmetic Methods
    """

    def __add__(lhs, rhs):
        return _add(lhs, rhs)

    def __sub__(lhs, rhs):
        return _sub(lhs, rhs)

    def __mul__(lhs not None, rhs not None):
        cdef V2 ret = V2.__new__(V2)
        cdef c.C2Data rhs_data

        if not v2_coerce(ret.data, lhs):
            raise TypeError("Expected V2 and number")
        if not v2_coerce(rhs_data, rhs):
            raise TypeError("Expected V2 and number")
        if type(lhs) == type(rhs):
            raise TypeError("Expected V2 and number")
        if not c.c2_mul_vector(ret.data, ret.data, rhs_data):
            raise RuntimeError("unknown error")
        return ret

    def __truediv__(lhs, rhs):
        cdef V2 ret = V2.__new__(V2)
        cdef c.C2Data rhs_data

        if not v2_coerce(ret.data, lhs):
            raise TypeError("Expected V2 and number")
        if not v2_coerce(rhs_data, rhs):
            raise TypeError("Expected V2 and number")
        if type(lhs) == type(rhs):
            raise TypeError("Expected V2 and number")
        if not c.c2_div_vector(ret.data, ret.data, rhs_data):
            raise ZeroDivisionError()
        return ret

    def scaled(V2 self, double ratio):
        cdef V2 ret = V2.__new__(V2)
        if not c.c2_mul_scalar(ret.data, self.data, ratio):
            raise RuntimeError("unknown error")
        return ret

    def rotated(V2 self, double radians):
        cdef V2 ret = V2.__new__(V2)
        if not c.c2_rotate_vector(ret.data, self.data, radians):
            raise RuntimeError("unknown error")
        return ret

    def approx(V2 self, V2 other not None):
        return c.c2_approx(self.data, other.data)

    def __repr__(V2 self):
        return 'V2(%f, %f)' % (self.data.x, self.data.y)

cdef class P2:

    @staticmethod
    def CCW(P2 p1 not None, P2 p2 not None, P2 p3 not None):
        return c.c2_ccw(p1.data, p2.data, p3.data)

    @staticmethod
    def Angle(P2 p1 not None, P2 p2 not None, P2 p3 not None):
        cdef double ret
        if not c.c2_points_acute_angle(ret, p1.data, p2.data, p3.data):
            raise ZeroDivisionError()
        return ret

    @property
    def x(self):
        return self.data.x

    @property
    def y(self):
        return self.data.y

    def __init__(P2 self, double x, double y):
        self.data.x = x
        self.data.y = y

    cpdef V2 vector(P2 self):
        cdef V2 ret = V2.__new__(V2)
        ret.data = self.data
        return ret

    def rotate(P2 self, double radians, P2 other=None):
        cdef P2 ret = P2.__new__(P2)
        cdef c.C2Data center = c.C2Data(0, 0) if other is None else other.data
        if not c.c2_rotate_around(ret.data, center, self.data, radians):
            raise RuntimeError("unknown error")
        return ret

    def __add__(lhs, rhs):
        return _add(lhs, rhs)

    def __sub__(lhs, rhs):
        return _sub(lhs, rhs)

    def __truediv__(lhs not None, rhs not None):
        cdef P2 ret = P2.__new__(P2)
        cdef c.C2Data rhs_data

        if not p2_coerce(ret.data, lhs):
            raise TypeError("Expected P2 and double")
        if not p2_coerce(rhs_data, rhs):
            raise TypeError("Expected P2 and double")
        if type(lhs) == type(rhs):
            raise TypeError("Expected P2 and double")
        if not c.c2_div_vector(ret.data, ret.data, rhs_data):
            raise ZeroDivisionError()
        return ret

    def __mul__(lhs not None, rhs not None):
        cdef P2 ret = P2.__new__(P2)
        cdef c.C2Data rhs_data

        if not p2_coerce(ret.data, lhs):
            raise TypeError("Expected V2 and number")
        if not p2_coerce(rhs_data, rhs):
            raise TypeError("Expected V2 and number")
        if type(lhs) == type(rhs):
            raise TypeError("Expected V2 and number")
        if not c.c2_mul_vector(ret.data, ret.data, rhs_data):
            raise RuntimeError("unknown error")
        return ret

    def approx(P2 self, P2 other not None):
        return c.c2_approx(self.data, other.data)

    def __repr__(P2 self):
        return 'P2(%f, %f)' % (self.data.x, self.data.y)