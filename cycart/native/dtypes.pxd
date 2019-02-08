from libcpp.pair cimport pair

#ctypedef pair[double, double] _I2

#cdef inline _I2 rtoi(_R2 data):
#    return _I2(data.x, data.y)

cdef struct _R2:
    double x
    double y

cdef struct _Line:
    double a
    double b
    double c

cdef struct _LineSegment:
    _R2 p1
    _R2 p2

cdef struct _Circle:
    _R2 center
    double radius
