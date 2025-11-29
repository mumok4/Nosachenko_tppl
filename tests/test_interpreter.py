# test_interpreter.py
import pytest

from interpreter import Interpreter

class TestInterpreter:
    inter = Interpreter()

    def test_simple_add(self):
        assert self.inter.eval("2+2") == 4
        assert self.inter.eval("2+3") == 5

    def test_simple_sub(self):
        assert self.inter.eval("2-2") == 0
        assert self.inter.eval("2-3") == -1

    def test_spaces(self):
        assert self.inter.eval("          2        +       2      ") == 4

    def test_numbers(self):
        assert self.inter.eval("22+22") == 44

    def test_add(self):
        assert self.inter.eval("2 + 2 + 3 + 4") == 11

    def test_single_number(self):
        assert self.inter.eval('13') == 13

    def test_mul(self):
        assert self.inter.eval('2*2*2') == 8

    def test_div(self):
        assert self.inter.eval('8/2/2') == 2

    def test_comp_mul(self):
        assert self.inter.eval('2 + 2 * 3') == 8

    def test_braces(self):
        assert self.inter.eval('(2 + 2) * 2') == 8