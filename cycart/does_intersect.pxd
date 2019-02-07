from .line cimport Line
from .line import Line

from .segment cimport LineSegment
from .segment import LineSegment

from .circle cimport Circle
from .circle import Circle

cpdef py_l2_l2_does_intersect(Line l1, Line l2)
cpdef py_ls2_ls2_does_intersect(LineSegment ls2, LineSegment ls2)
cpdef py_c2_c2_does_intersect(Circle c1, Circle c2)