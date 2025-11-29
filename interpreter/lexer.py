# lexer.py
from .token import TokenType, Token




class Lexer():


    def __init__(self):
        self._pos = 0
        self._current_char = None
        self._text = ""


    def __skip(self):
        while self._current_char is not None and self._current_char.isspace():
            self.__forward()


    def __forward(self):
        self._pos += 1
        if self._pos > len(self._text) - 1:
            self._current_char = None
        else:
            self._current_char = self._text[self._pos]


    def __number(self) -> str:
        result = ""
        while self._current_char is not None and self._current_char.isdigit():
            result += self._current_char
            self.__forward()
        return result


    def next_token(self) -> Token:
        while self._current_char is not None:
            if self._current_char.isspace():
                self.__skip()
                continue

            if self._current_char.isdigit():
                return Token(TokenType.NUMBER, self.__number())

            if self._current_char in ('+', '-', '*', '/'):
                char = self._current_char
                self.__forward()
                return Token(TokenType.OPERATOR, char)
            
            if self._current_char == "(":
                self.__forward()
                return Token(TokenType.LPAREN, self._current_char)
            
            if self._current_char == ")":
                self.__forward()
                return Token(TokenType.RPAREN, self._current_char)

            raise SyntaxError(f"Unexpected character: {self._current_char}")

        return Token(TokenType.EOL, "")
    

    def set_text(self, expression: str):
        self._pos = 0
        self._text = expression
        self._current_char = self._text[self._pos]