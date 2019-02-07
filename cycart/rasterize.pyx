import numpy as np

cimport cycart.ctypes as c

from cycart.line cimport LineSegment
from cycart.line import LineSegment

from cycart.circle cimport Circle
from cycart.circle import Circle

def rasterize_line_segment(LineSegment segment not None, n=20):
    cdef c.C2Data start, step

    xs = np.zeros()

def rasterize_circle(Circle circle not None, n=180):
    pass

#def rasterize_polygon(Polygon polygon not None, n=None):
#    n = n if n else len(polygon) * 20

