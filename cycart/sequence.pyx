from cpython cimport array
import array

from libcpp.vector cimport vector

from cycart.native.dtypes cimport _R2
from cycart.native.space cimport r2_approx

from cycart.space cimport P2, py_p2_new, py_p2_extract
from cycart.space import P2

from collections.abc import Sequence, MutableSequence

cdef _R2[::1] r2_buffer(object[double, ndim=2] points):
    assert points.shape[1] == 2
    return <_R2[:points.shape[0]]><void*>&points[0, 0]

cdef class P2Sequence:

    @staticmethod
    def from_buffer(object[double, ndim=2] points not None):
        cdef P2Sequence seq = P2Sequence.__new__(P2Sequence)
        seq._set_buffer(points)
        return seq

    @property
    def xs(P2Sequence self):
        return array.array('d', self._buffer()[:, 0])

    @property
    def ys(P2Sequence self):
        return array.array('d', self._buffer()[:, 1])

    def __init__(P2Sequence self, points=None):
        if points is None:
            return

        for point in points:
            self.__data.push_back(py_p2_extract(point))

    cdef void _set_buffer(P2Sequence self, object[double, ndim=2] points):
        cdef _R2[::1] buffer = r2_buffer(points)
        self.__data.resize(buffer.size)
        cdef size_t idx
        for idx in range(buffer.size):
            self.__data[idx] = buffer[idx]

    cdef double[:,::1] _buffer(P2Sequence self):
        return <double[:self.__data.size(),:2]><double*>self.__data.data()

    cdef _R2[::1] _r2_buffer(P2Sequence self):
        return <_R2[:self.__data.size()]>self.__data.data()

    def export(P2Sequence self, object[double, ndim=2] points not None):
        cdef _R2[::1] output = r2_buffer(points)
        cdef size_t size = min(output.size, self.__data.size())

        cdef size_t idx
        for idx in range(size):
            output[idx] = self.__data[idx]

    """
    Sequence Interface Methods
    """

    def __len__(P2Sequence self):
        return self.__data.size()

    def __iter__(P2Sequence self):
        cdef long idx
        for idx in range(self.__data.size()):
            yield py_p2_new(self.__data[idx])

    def __getitem__(P2Sequence self, long idx):
        if idx < 0:
            idx = idx % self.__data.size()
            print(idx)
        elif idx >= self.__data.size():
            raise IndexError()
        return py_p2_new(self.__data[idx])

    def __contains__(P2Sequence self, P2 point):
        cdef size_t idx
        for idx in range(self.__data.size()):
            if r2_approx(self.__data[idx], point.data):
                return True
        return False

    def __reversed__(P2Sequence self):
        pass

    def index(P2Sequence self, P2 point, long start=0, object stop=None):
        cdef long idx_stop = self.__data.size() if stop is None else stop
        cdef long idx
        for idx in range(start, idx_stop):
            if r2_approx(self.__data[idx], point.data):
                return idx
        raise ValueError()

    def count(P2Sequence self, P2 point):
        cdef size_t total = 0
        cdef size_t idx
        for idx in range(self.__data.size()):
            if r2_approx(self.__data[idx], point.data):
                total += 1
        return total

Sequence.register(P2Sequence)

cdef class P2MutableSequence(P2Sequence):

    @staticmethod
    def from_buffer(object[double, ndim=2] points):
        cdef P2MutableSequence seq = P2MutableSequence.__new__(P2MutableSequence)
        seq._set_buffer(points)
        return seq

    def __setitem__(P2MutableSequence self, size_t key, P2 value):
        self.__data[key] = value

    def append(P2MutableSequence self, P2 point):
        self._append(point.data)

    cdef _append(P2MutableSequence self, _R2 point):
        self.__data.push_back(point)

    def extend(P2MutableSequence self, object points not None):
        for point in points:
            self.__data.push_back(py_p2_extract(point))

    def extend_seq(P2MutableSequence self, P2Sequence sequence not None):
        self._extend_buffer(sequence._r2_buffer())

    def extend_buffer(P2MutableSequence self, object[double, ndim=2] points):
        self._extend_buffer(r2_buffer(points))

    cdef _extend_buffer(P2MutableSequence self, object[_R2, ndim=1] points):
        cdef size_t old_size = self.__data.size()
        cdef size_t new_size = old_size + points.size
        self.__data.resize(new_size)
        cdef size_t idx
        for idx in range(points.size):
            self.__data[old_size + idx] = points[idx]

MutableSequence.register(P2MutableSequence)