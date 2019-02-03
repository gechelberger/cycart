cimport cython

cimport cycart.ctypes as c

cdef class V2:
    cdef c.C2Data data

    cpdef P2 point(V2 self)

cdef class P2:
    cdef c.C2Data data

    cpdef V2 vector(P2 self)


"""
V2 / P2 combinations
"""


cdef inline V2 v2_v2_add(V2 lhs, V2 rhs):
    cdef V2 ret = V2.__new__(V2)
    if not c.c2_add_vector(ret.data, lhs.data, rhs.data):
        raise RuntimeError("unknown error")
    return ret

cdef inline V2 v2_v2_sub(V2 lhs, V2 rhs):
    cdef V2 ret = V2.__new__(V2)
    if not c.c2_sub_vector(ret.data, lhs.data, rhs.data):
        raise RuntimeError("unknown error")
    return ret

cdef inline P2 p2_v2_add(P2 lhs, V2 rhs):
    cdef P2 ret = P2.__new__(P2)
    if not c.c2_add_vector(ret.data, lhs.data, rhs.data):
        raise RuntimeError("unknown error")
    return ret

cdef inline P2 p2_v2_sub(P2 lhs, V2 rhs):
    cdef P2 ret = P2.__new__(P2)
    if not c.c2_sub_vector(ret.data, lhs.data, rhs.data):
        raise RuntimeError("unknown error")
    return ret

cdef inline P2 v2_p2_sub(V2 lhs, P2 rhs):
    cdef P2 ret = P2.__new__(P2)
    if not c.c2_sub_vector(ret.data, lhs.data, rhs.data):
        raise RuntimeError("unknown error")
    return ret

cdef inline V2 p2_p2_sub(P2 lhs, P2 rhs):
    cdef V2 ret = V2.__new__(V2)
    if not c.c2_sub_vector(ret.data, lhs.data, rhs.data):
        raise RuntimeError("unknown error")
    return ret

cdef inline bint v2_coerce(c.C2Data& out, py_obj):
    op_type = type(py_obj)
    if op_type is V2:
        v2_extract(out, py_obj)
    elif op_type is float or op_type is int:
        out.x = py_obj
        out.y = py_obj
    else:
        return 0
    return 1

cdef inline bint p2_coerce(c.C2Data& out, py_obj):
    op_type = type(py_obj)
    if op_type is P2:
        p2_extract(out, py_obj)
    elif op_type is float or op_type is int:
        out.x = py_obj
        out.y = py_obj
    else:
        return 0
    return 1

cdef inline void p2_extract(c.C2Data& out, P2 py_obj):
    (&out)[0] = py_obj.data

cdef inline void v2_extract(c.C2Data& out, V2 py_obj):
    (&out)[0] = py_obj.data