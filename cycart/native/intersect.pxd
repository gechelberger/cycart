from libcpp.set cimport set

from .dtypes cimport _R2, _Line, _LineSegment, _Circle

from .errors cimport SUCCESS, ERROR, UNKNOWN_ERROR, DIV_ZERO_ERROR

from .line cimport l2_ref_by_points
from .segment cimport ls2_contains


cdef inline ERROR l2_l2_intersect_set(set[_R2]& out, const _Line& l1, const _Line& l2):
    cdef ERROR code
    cdef _R2 candidate

    code = l2_l2_intersect(candidate, l1, l2)
    if code != SUCCESS:
        return code

    set.insert(candidate)

cdef inline ERROR c2_c2_intersect_set(set[_R2]& out, const _Circle& c1, const _Circle& c2):
    pass

cdef inline ERROR ls2_ls2_intersect_set(set[_R2]& out, const _LineSegment& ls1, const _LineSegment& ls2):
    pass

cdef inline ERROR ls2_c2_intersect_set(set[_R2]& out, const _LineSegment& seg, const _Circle circle):

    return UNKNOWN_ERROR

cdef inline ERROR ls2_l2_intersect_set(set[_R2]& out, const _LineSegment& seg, const _Line line):
    cdef _Line seg_line
    if not l2_ref_by_points(seg_line, seg.p1, seg.p2):
        return UNKNOWN_ERROR

    cdef _R2 candidate
    cdef ERROR code = l2_l2_intersect(candidate, seg_line, line)
    if code != SUCCESS:
        return code

    if ls2_contains(seg, candidate):
        out.insert(candidate)

    return SUCCESS

cdef inline ERROR l2_c2_intersect_set(set[_R2]& out, const _Line& line, const _Circle circle):
    return UNKNOWN_ERROR


cdef inline ERROR l2_l2_intersect(_R2& out, const _Line& l1, const _Line& l2):
    cdef det = l1.a * l2.b - l1.b * l2.a
    if det == 0:
        return DIV_ZERO_ERROR
    out.x = (l2.b * l1.c - l1.b * l2.c) / det
    out.y = (l1.a * l2.c - l2.a * l1.c) / det
    return SUCCESS