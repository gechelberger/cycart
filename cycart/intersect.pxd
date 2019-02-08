from libcpp.vector cimport vector

from cycart.native.dtypes cimport _R2

from cycart.space cimport py_p2_new


cdef inline py_p2_set_new(vector[_R2]& i2set):
    # can't make this (const vector[_R2]& ) because cython for ... in ... always
    # creates a non-const iterator... booooo
    py_vals = set()
    for i2 in i2set:
        py_vals.add(py_p2_new(i2))
    return py_vals