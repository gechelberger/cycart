import pytest

from cycart import P2Sequence, P2

from collections.abc import Sequence

def test_sequence_create():
    empty = P2Sequence()
    assert len(empty.xs) == 0

    one = P2Sequence([P2(5,5)])
    assert one[0] == P2(5,5)

def test_sequence_abc():
    empty = P2Sequence()
    assert isinstance(empty, Sequence)