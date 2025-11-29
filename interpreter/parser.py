# parser.py
from .lexer import Lexer
from .token import Token, TokenType
from .ast import Number, BinOp, Node




class Parser():


    def __init__(self, lexer: Lexer):
        self._current_token = None
        self._lexer = lexer

    
    def __check_token_type(self, type_: TokenType):

        if self._current_token.type_ == type_:
            self._current_token = self._lexer.next_token()

        else:
            raise SyntaxError("Invalid token type")
        
    
    def __factor(self) -> Node:
        token = self._current_token

        if token.type_ == TokenType.NUMBER:
            self.__check_token_type(TokenType.NUMBER)
            return Number(token)
        
        if token.type_ == TokenType.LPAREN:
            self.__check_token_type(TokenType.LPAREN)
            result = self.__expr()
            self.__check_token_type(TokenType.RPAREN)
            return result
        
        raise SyntaxError("Invalid factor")
    

    def __term(self) -> Node:
        result = self.__factor()

        while (self._current_token is not None and self._current_token.type_ == TokenType.OPERATOR):
            
            if self._current_token.value not in ['*', '/']:
                break
            
            token = self._current_token
            self.__check_token_type(TokenType.OPERATOR)
            return BinOp(result, token, self.__factor())

        return result


    def __expr(self) -> Node:
        result = self.__term()
        
        while (self._current_token is not None and self._current_token.type_ == TokenType.OPERATOR):
            
            if self._current_token.value not in ['+', '-']:
                break

            token = self._current_token
            self.__check_token_type(TokenType.OPERATOR)
            return BinOp(result, token, self.__factor())

        return result
    

    def parse(self, text: str):
        self._lexer.set_text(text)
        self._current_token = self._lexer.next_token()
        return self.__expr()
    