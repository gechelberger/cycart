from cycart.native.space cimport _R2, r2_add, r2_sub

cdef class R2:
    cdef _R2 data

cdef class V2(R2):

    cpdef P2 point(V2 self)

cdef class P2(R2):

    cpdef V2 vector(P2 self)


"""
V2 / P2 combinations
"""

cdef inline V2 py_v2_new(const _R2& data):
    cdef V2 ret = V2.__new__(V2)
    ret.data = data
    return ret

cdef inline P2 py_p2_new(const _R2& data):
    cdef P2 ret = P2.__new__(P2)
    ret.data = data
    return ret

cdef inline V2 v2_v2_sub(V2 lhs, V2 rhs):
    return py_v2_new(r2_sub(lhs.data, rhs.data))

cdef inline P2 p2_v2_sub(P2 lhs, V2 rhs):
    return py_p2_new(r2_sub(lhs.data, rhs.data))

cdef inline P2 v2_p2_sub(V2 lhs, P2 rhs):
    return py_p2_new(r2_sub(lhs.data, rhs.data))

cdef inline V2 p2_p2_sub(P2 lhs, P2 rhs):
    return py_v2_new(r2_sub(lhs.data, rhs.data))

cdef inline bint v2_coerce(_R2& out, py_obj):
    if isinstance(py_obj, V2):
        v2_extract(out, py_obj)
    elif isinstance(py_obj, (float, int)):
        out.x = py_obj
        out.y = py_obj
    else:
        return 0
    return 1

cdef inline bint p2_coerce(_R2& out, py_obj):
    op_type = type(py_obj)
    if op_type is P2:
        p2_extract(out, py_obj)
    elif op_type is float or op_type is int:
        out.x = py_obj
        out.y = py_obj
    else:
        return 0
    return 1

cdef inline void p2_extract(_R2& out, P2 py_obj):
    (&out)[0] = py_obj.data

cdef inline void v2_extract(_R2& out, V2 py_obj):
    (&out)[0] = py_obj.data

cdef inline _R2 py_p2_extract(P2 py_obj):
    return py_obj.data

cdef inline _R2 py_v2_extract(V2 py_obj):
    return py_obj.data