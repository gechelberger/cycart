from libcpp.vector cimport vector

cimport cycart.native.intersect as cni

from cycart.native.dtypes cimport _R2

from cycart.circle cimport Circle
from cycart.circle import Circle

from cycart.line cimport Line
from cycart.line import Line

from cycart.segment cimport LineSegment
from cycart.segment import LineSegment

from multipledispatch import Dispatcher

dispatcher = Dispatcher("intersect")


def intersect(Line l1 not None, Line l2 not None):
    cdef vector[_R2] collect
    if not cni.l2_l2_intersect_set(collect, l1.data, l2.data):
        raise ValueError()
    return py_p2_set_new(collect)
dispatcher.add((Line, Line), intersect)

def intersect(LineSegment ls1 not None, LineSegment ls2 not None):
    cdef vector[_R2] collect
    if not cni.ls2_ls2_intersect_set(collect, ls1.data, ls2.data):
        raise ValueError()
    return py_p2_set_new(collect)
dispatcher.add((LineSegment, LineSegment), intersect)

def intersect(Circle c1 not None, Circle c2 not None):
    cdef vector[_R2] collect
    if not cni.c2_c2_intersect_set(collect, c1.data, c2.data):
        raise ValueError()
    return py_p2_set_new(collect)
dispatcher.add((Circle, Circle), intersect)

def intersect(Line line not None, LineSegment seg not None):
    return py_ls2_l2_intersect(seg, line)
dispatcher.add((Line, LineSegment), intersect)

def intersect(LineSegment seg not None, Line line not None):
    return py_ls2_l2_intersect(seg, line)
dispatcher.add((LineSegment, Line), intersect)

def intersect(LineSegment seg not None, Circle circle not None):
    return py_ls2_c2_intersect(seg, circle)
dispatcher.add((LineSegment, Circle), intersect)

def intersect(Circle circle not None, LineSegment seg not None):
    return py_ls2_c2_intersect(seg, circle)
dispatcher.add((Circle, LineSegment), intersect)

def intersect(Line line not None, Circle circle not None):
    return py_l2_c2_intersect(line, circle)
dispatcher.add((Line, Circle), intersect)

def intersect(Circle circle not None, Line line not None):
    return py_l2_c2_intersect(line, circle)
dispatcher.add((Circle, Line), intersect)

intersect = dispatcher

"""
impls
"""

cdef py_ls2_l2_intersect(LineSegment seg, Line line):
    cdef vector[_R2] collect
    if not cni.ls2_l2_intersect_set(collect, seg.data, line.data):
        raise ValueError()
    return py_p2_set_new(collect)

cdef py_ls2_c2_intersect(LineSegment seg, Circle circle):
    cdef vector[_R2] collect
    if not cni.ls2_c2_intersect_set(collect, seg.data, circle.data):
        raise ValueError()
    return py_p2_set_new(collect)

cdef py_l2_c2_intersect(Line line, Circle circle):
    cdef vector[_R2] collect
    if not cni.l2_c2_intersect_set(collect, line.data, circle.data):
        raise ValueError()
    return py_p2_set_new(collect)