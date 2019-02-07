cimport cycart.native.does_intersect as ndi

from cycart.circle cimport Circle
from cycart.circle import Circle

from cycart.line cimport Line
from cycart.line import Line

from cycart.segment cimport LineSegment
from cycart.segment import LineSegment

from libc.math cimport fabs

from multipledispatch import dispatch

@dispatch(Line, Line)
def does_intersect(Line l1 not None, Line l2 not None):
    return py_l2_l2_does_intersect(l1, l2)

@dispatch(LineSegment, LineSegment)
def does_intersect(LineSegment ls1 not None, Line ls2 not None):
    return py_ls2_ls2_does_intersect(ls1, ls2)

@dispatch(Circle, Circle)
def does_intersect(Circle c1 not None, Circle c2 not None):
    return py_c2_c2_does_intersect(c1, c2)

@dispatch(LineSegment, Line)
def does_intersect(LineSegment seg not None, Line line not None):
    return py_ls2_l2_does_intersect(seg, line)

@dispatch(Line, LineSegment)
def does_intersect(Line line not None, LineSegment seg not None):
    return py_ls2_l2_does_intersect(seg, line)

@dispatch(LineSegment, Circle)
def does_intersect(LineSegment seg not None, Circle circle not None):
    return py_ls2_c2_does_intersect(seg, circle)

@dispatch(Circle, LineSegment)
def does_intersect(Circle circle not None, LineSegment seg not None):
    return py_ls2_c2_does_intersect(seg, circle)

@dispatch(Line, Circle)
def does_intersect(Line line not None, Circle circle not None):
    return py_l2_c2_does_intersect(line, circle)

@dispatch(Circle, Line)
def does_intersect(Circle circle not None, Line line not None):
    return py_l2_c2_does_intersect(line, circle)

"""
impls
"""

cpdef py_l2_l2_does_intersect(Line l1, Line l2):
    cdef ndi.IRES res = ndi.l2_l2_does_intersect(l1.data, l2.data)
    if res == ndi.ERROR:
        raise ValueError("Could not find intersection for lines (%r, %r)" % (l1, l2))
    return bool(res)

cpdef py_ls2_ls2_does_intersect(LineSegment ls1, LineSegment ls2):
    cdef ndi.IRES res = ndi.ls2_ls2_does_intersect(ls1.data, ls2.data)
    if res == ndi.ERROR:
        raise ValueError("Could not find intersection for segments (%r, %r)" % (ls1, ls2))
    return bool(res)

cpdef py_c2_c2_does_intersect(Circle c1, Circle c2):
    cdef ndi.IRES res = ndi.c2_c2_does_intersect(c1, c2)
    if res == ndi.ERROR:
        raise ValueError("Could not find intersection for circles (%r, %r)" % (c1, c2))
    return bool(res)

cpdef py_ls2_l2_does_intersect(LineSegment seg, Line line):
    cdef ndi.IRES res = ndi.ls2_l2_does_intersect(seg.data, line.data)
    if res == ndi.ERROR:
        raise ValueError("Could not find intersection (%r, %r" % (seg, line))
    return bool(res)

cpdef py_ls2_c2_does_intersect(LineSegment seg, Circle circle):
    cdef ndi.IRES res = ndi.ls2_c2_does_intersect(seg.data, circle.data)
    if res == ndi.ERROR:
        raise ValueError("Could not find intersection (%r, %r)" % (seg, circle))
    return bool(res)

cpdef py_l2_c2_does_intersect(Line line, Circle circle):
    cdef ndi.IRES res = ndi.l2_c2_does_intersect(line.data, circle.data)
    if res == ndi.ERROR:
        raise ValueError("Could not find intersection (%r, %r)" % (line, circle))
    return bool(res)

#todo: polygons