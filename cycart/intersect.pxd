cimport cycart.cytypes as c
from cycart.ctypes cimport C2Data, LineData, LineSegmentData, CircleData

from libcpp.set cimport set

"""
Intersect Functions
"""

cdef inline set[C2Data] intersect_line_line(const LineData& l1, const LineData& l2):
    cdef set[C2Data] ret
    cdef C2Data temp

    if c.line_line_intersect(temp, l1, l2):
        ret.insert(temp)
    return ret

cdef inline set[C2Data] intersect_segment_segment(const LineSegmentData& s1, LineSegmentData& s2):
    cdef set[C2Data] ret
    cdef C2Data temp

    if c.segment_segment_intersect(temp, s1, s2):
        ret.insert(s1)
    return ret

cdef inline set[C2Data] intersect_circle_circle(const CircleData& c1, const CircleData& c2):
    cdef set[C2Data] ret
    cdef C2Data temp

    pass

cdef inline set[C2Data] intersect_line_segment(const LineData& line, const LineSegmentData& segment):
    cdef set[C2Data] ret
    cdef LineData temp_line
    cdef C2Data temp

    if not c.line_by_points(segment.p1, segment.p2):
        return ret

    if not c.line_line_intersect(temp, line, temp_line):
        return ret

    if c.segment_contains(segment, temp):
        ret.insert(temp)

    return ret

cdef inline set[C2Data] intersect_line_circle(const LineData& line, const CircleData& circle):
    cdef set[C2Data] ret
    cdef LineData temp_line
    cdef C2Data p1, p2

    if not c.c2_line_translate(temp_line, line, c.c2_negative(circle.center)):
        return ret

cdef inline set[C2Data] intersect_segment_circle(const LineSegmentData& segment, const CircleData& circle):
    pass

"""
Does Intersect Functions
"""

cdef inline bint does_intersect()