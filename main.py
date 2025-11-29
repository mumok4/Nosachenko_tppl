from interpreter.interpreter import Interpreter
from interpreter.parser import Parser
from interpreter.lexer import Lexer

text = '2+2*2'
lexer = Lexer()
parser = Parser(lexer)

print(parser.parse(text))

inter = Interpreter()
print(inter.eval(text))