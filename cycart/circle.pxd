from cycart.native.dtypes cimport _Circle

cdef class Circle:
    cdef _Circle data

cdef inline Circle py_circle_new(_Circle data):
    cdef Circle circle = Circle.__new__(Circle)
    circle.data = data
    return circle