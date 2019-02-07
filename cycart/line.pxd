from cycart.native.line cimport _Line

cdef class Line:
    cdef _Line data

cdef inline Line py_line_new(_Line data):
    cdef Line line = Line.__new__(Line)
    line.data = data
    return line