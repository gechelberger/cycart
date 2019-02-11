from cpython cimport array
import array

from collections.abc import Sequence, MutableSequence

from libcpp.vector cimport vector

from cycart.native.dtypes cimport _R2

from cycart.space cimport P2, py_p2_new, py_p2_extract
from cycart.space import P2

cdef inline _R2[::1] r2_buffer(object[double, ndim=2] points):
    return <_R2[:points.shape[0]]>&points[0, 0]

cdef class P2Sequence(Sequence):

    @classmethod
    def frombuffer(cls, object[double, ndim=2] data not None):
        cdef cls seq = cls.__new__(cls)
        seq.__data.resize(data.shape[0])
        cdef _R2[::1] buffer = r2_buffer(data)
        cdef size_t idx
        for idx in range(data.shape[0]):
            seq.__data[idx] = buffer[idx]
        return seq

    @property
    def xs(P2Sequence self):
        return array.array('d', self._buffer()[:, 0])

    @property
    def ys(P2Sequence self):
        return array.array('d', self._buffer()[:, 1])

    def __init__(P2Sequence self, points):
        for point in points:
            self.__data.push_back(py_p2_extract(point))

    cdef _R2[::1] _buffer(P2Sequence self):
        return <_R2[:self.__data.size()]>self.__data.data()

    def __len__(P2Sequence self):
        return self.__data.size()

    def __iter__(P2Sequence self):
        cdef long idx
        for idx in range(self.__data.size()):
            yield py_p2_new(self.__data[idx])

    def __getitem__(P2Sequence self, idx not None):
        return py_p2_new(self.__data[idx])

    def export(P2Sequence self, object[double, ndim=2] points not None):
        cdef _R2[::1] output = r2_buffer(points)
        cdef size_t size = min(output.size, self.__data.size())

        cdef size_t idx
        for idx in range(size):
            output[idx] = self.__data[idx]

cdef class P2MutableSequence(P2Sequence, MutableSequence):

    def append(P2MutableSequence self, P2 point):
        self._append(point.data)

    cdef _append(P2MutableSequence self, _R2 point):
        self.__data.push_back(point)

    def extend(P2MutableSequence self, P2Sequence sequence not None):
        self._extendbuffer(r2_buffer(sequence._buffer()))

    def extendbuffer(P2MutableSequence self, object[double, ndim=2] points):
        self._extendbuffer(r2_buffer(points))

    cdef _extendbuffer(P2MutableSequence self, object[_R2, ndim=1] points):
        cdef size_t old_size = self.__data.size()
        cdef size_t new_size = old_size + points.size
        self.__data.resize(new_size)
        cdef size_t idx
        for idx in range(points.size):
            self.__data[old_size + idx] = points[idx]

