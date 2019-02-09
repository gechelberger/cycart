from cycart.native.space cimport (
    _R2,
    r2_mul,
    r2_mul2,
    r2_dot,
    r2_cross,
    r2_ref_div2,
    r2_rotate,
    r2_rotate_around,
    r2_approx,
    r2_ccw,
    r2_ref_point_angle,
)


"""

"""

def _add(R2 lhs not None, R2 rhs not None):
    lhs_type = type(lhs)
    rhs_type = type(rhs)


    if lhs_type is V2 and rhs_type is V2:
        return py_v2_new(r2_add(lhs.data, rhs.data))
    if lhs_type is P2 and rhs_type is V2:
        return py_p2_new(r2_add(lhs.data, rhs.data))
    if lhs_type is V2 and rhs_type is P2:
        return py_p2_new(r2_add(lhs.data, rhs.data))
    raise TypeError(
        "Expected Types: V2 or P2. Got: %s, %s"
        % (lhs_type.__name__, rhs_type.__name__)
    )


def _sub(R2 lhs not None, R2 rhs not None):
    lhs_type = type(lhs)
    rhs_type = type(rhs)
    if lhs_type is V2 and rhs_type is V2:
        return py_v2_new(r2_sub(lhs.data, rhs.data))
    if lhs_type is P2 and rhs_type is V2:
        return py_p2_new(r2_sub(lhs.data, rhs.data))
    if lhs_type is V2 and rhs_type is P2:
        return py_p2_new(r2_sub(lhs.data, rhs.data))
    raise TypeError(
        "Expected Types: V2 or P2. Got: %s, %s"
        % (lhs_type.__name__, rhs_type.__name__)
    )

"""

"""

cdef class V2(R2):

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
        if isinstance(lhs, R2) and isinstance(rhs, R2):
            return _add(lhs, rhs)
        return NotImplemented

    def __sub__(lhs, rhs):
        if isinstance(lhs, R2) and isinstance(rhs, R2):
            return _sub(lhs, rhs)
        return NotImplemented

    def __mul__(lhs not None, rhs not None):
        cdef _R2 lhs_data, rhs_data

        if not v2_coerce(lhs_data, lhs):
            raise TypeError("Expected V2 and number")
        if not v2_coerce(rhs_data, rhs):
            raise TypeError("Expected V2 and number")
        if type(lhs) == type(rhs):
            raise TypeError("Expected V2 and number")

        return py_v2_new(r2_mul2(lhs_data, rhs_data))

    def __truediv__(lhs, rhs):
        cdef V2 ret = V2.__new__(V2)
        cdef _R2 rhs_data

        if not v2_coerce(ret.data, lhs):
            raise TypeError("Expected V2 and number")
        if not v2_coerce(rhs_data, rhs):
            raise TypeError("Expected V2 and number")
        if type(lhs) == type(rhs):
            raise TypeError("Expected V2 and number")

        if not r2_ref_div2(ret.data, ret.data, rhs_data):
            raise ZeroDivisionError()
        return ret

    def dot(V2 lhs, V2 rhs not None):
        return r2_dot(lhs.data, rhs.data)

    def cross(V2 lhs, V2 rhs not None):
        return r2_cross(lhs.data, rhs.data)


    def scaled(V2 self, double ratio):
        return py_v2_new(r2_mul(self.data, ratio))

    def rotated(V2 self, double radians):
        cdef V2 ret = V2.__new__(V2)
        ret.data = r2_rotate(self.data, radians)
        return ret

    def approx(V2 self, V2 other not None, double rtol=1e-9, double atol=0):
        return r2_approx(self.data, other.data, rtol, atol)

    def __eq__(lhs, rhs):
        if isinstance(lhs, V2) and isinstance(rhs, V2):
            return lhs.approx(rhs)
        return NotImplemented

    def __repr__(V2 self):
        return 'V2(%f, %f)' % (self.data.x, self.data.y)

    def __hash__(V2 self):
        return hash((self.data.x, self.data.y))


cdef class P2(R2):

    @staticmethod
    def CCW(P2 p1 not None, P2 p2 not None, P2 p3 not None):
        return r2_ccw(p1.data, p2.data, p3.data)

    @staticmethod
    def Angle(P2 p1 not None, P2 p2 not None, P2 p3 not None):
        cdef double ret
        if not r2_ref_point_angle(ret, p1.data, p2.data, p3.data):
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
        return py_v2_new(self.data)

    def rotate(P2 self, double radians, P2 center=None):
        cdef _R2 _center = _R2(0, 0) if center is None else center.data
        return py_p2_new(r2_rotate_around(self.data, _center, radians))

    def __add__(lhs, rhs):
        if isinstance(lhs, R2) and isinstance(rhs, R2):
            return _add(lhs, rhs)
        return NotImplemented

    def __sub__(lhs, rhs):
        if isinstance(lhs, R2) and isinstance(rhs, R2):
            return _sub(lhs, rhs)
        return NotImplemented

    def __truediv__(lhs not None, rhs not None):
        cdef _R2 r2_lhs, r2_rhs

        if not p2_coerce(r2_lhs, lhs):
            raise TypeError("Expected P2 and double")
        if not p2_coerce(r2_rhs, rhs):
            raise TypeError("Expected P2 and double")
        if type(lhs) == type(rhs):
            raise TypeError("Expected P2 and double")

        cdef P2 ret = P2.__new__(P2)
        if not r2_ref_div2(ret.data, r2_lhs, r2_rhs):
            raise ZeroDivisionError()
        return ret

    def __mul__(lhs not None, rhs not None):
        cdef _R2 r2_lhs, r2_rhs

        if not p2_coerce(r2_lhs, lhs):
            raise TypeError("Expected V2 and number")
        if not p2_coerce(r2_rhs, rhs):
            raise TypeError("Expected V2 and number")
        if type(lhs) == type(rhs):
            raise TypeError("Expected V2 and number")
        return py_p2_new(r2_mul2(r2_lhs, r2_rhs))

    def approx(P2 self, P2 other not None, double rtol=1e-9, double atol=0):
        return r2_approx(self.data, other.data, rtol, atol)

    def __eq__(lhs, rhs):
        if isinstance(lhs, P2) and isinstance(rhs, P2):
            return lhs.approx(rhs)
        return NotImplemented

    def __repr__(P2 self):
        return 'P2(%f, %f)' % (self.x, self.y)

    def __hash__(self):
        return hash((self.x, self.y))