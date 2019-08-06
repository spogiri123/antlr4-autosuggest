/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

grammar HarmonySQL_test;

@members {
  /**
   * Verify whether current token is a valid decimal token (which contains dot).
   * Returns true if the character that follows the token is not a digit or letter or underscore.
   *
   * For example:
   * For char stream "2.3", "2." is not a valid decimal token, because it is followed by digit '3'.
   * For char stream "2.3_", "2.3" is not a valid decimal token, because it is followed by '_'.
   * For char stream "2.3W", "2.3" is not a valid decimal token, because it is followed by 'W'.
   * For char stream "12.0D 34.E2+0.12 "  12.0D is a valid decimal token because it is followed
   * by a space. 34.E2 is a valid decimal token because it is followed by symbol '+'
   * which is not a digit or letter or underscore.
   */
  public boolean isValidDecimal() {
    int nextChar = _input.LA(1);
    if (nextChar >= 'A' && nextChar <= 'Z' || nextChar >= '0' && nextChar <= '9' ||
      nextChar == '_') {
      return false;
    } else {
      return true;
    }
  }
}

query: singleQrySrc groupByExpression?
                selectClause?
                orderByExpr?
                limitOffset? EOF;

querySrc: commaDelimitedQueries | spaceDelimitedQueries ;

commaDelimitedQueries: singleQrySrc (K_COMMA singleQrySrc)* ;

spaceDelimitedQueries: singleQrySrc singleQrySrc* ;

selectClause: K_SELECT selectExpr ;
selectExpr: selectExpression (K_COMMA selectExpression)* ;
selectExpression: expr (K_AS identifier)? ;

singleQrySrc: fromClause | whereClause | fromExpression | expr ;

fromClause: K_FROM fromExpression ;
fromExpression: fromSrc whereClause? ;
fromSrc: aliasExpr | (identifier | literal) ;
whereClause: K_WHERE expr ;

expr: compE exprRight* ;
compE: comparisonClause
    | isClause
    | hasClause
    | arithE
    | countClause
    | maxClause
    | minClause
    | sumClause
    ;
comparisonClause: arithE operator arithE ;
arithE: multiE arithERight* ;
arithERight: (K_PLUS | K_MINUS) multiE ;
multiE: atomE multiERight* ;
multiERight: (K_STAR | K_DIV) atomE ;
atomE: (identifier | literal) | K_LPAREN expr K_RPAREN ;

isClause: arithE (K_ISA | K_IS) identifier ;
hasClause: arithE K_HAS identifier ;
countClause: K_COUNT K_LPAREN K_RPAREN ;
maxClause: K_MAX K_LPAREN expr K_RPAREN ;
minClause: K_MIN K_LPAREN expr K_RPAREN ;
sumClause: K_SUM K_LPAREN expr K_RPAREN ;
exprRight: (K_AND | K_OR) compE ;

aliasExpr: (identifier | literal) K_AS identifier ;
groupByExpression: K_GROUPBY K_LPAREN selectExpr K_RPAREN ;
orderByExpr: K_ORDERBY expr sortOrder? ;

limitOffset: limitClause offsetClause? ;
// Composite rules
limitClause: K_LIMIT NUMBER ;
offsetClause: K_OFFSET NUMBER ;

operator: (K_LT | K_LTE | K_EQ | K_NEQ | K_GT | K_GTE | K_LIKE) ;
sortOrder: K_ASC | K_DESC ;
valueArray: K_LBRACKET ID (K_COMMA ID)* K_RBRACKET ;
literal: BOOL | NUMBER | FLOATING_NUMBER | (ID | valueArray) ;

// Core rules
identifier: ID ;

fragment A: ('A'|'a');
fragment B: ('B'|'b');
fragment C: ('C'|'c');
fragment D: ('D'|'d');
fragment E: ('E'|'e');
fragment F: ('F'|'f');
fragment G: ('G'|'g');
fragment H: ('H'|'h');
fragment I: ('I'|'i');
fragment J: ('J'|'j');
fragment K: ('K'|'k');
fragment L: ('L'|'l');
fragment M: ('M'|'m');
fragment N: ('N'|'n');
fragment O: ('O'|'o');
fragment P: ('P'|'p');
fragment Q: ('Q'|'q');
fragment R: ('R'|'r');
fragment S: ('S'|'s');
fragment T: ('T'|'t');
fragment U: ('U'|'u');
fragment V: ('V'|'v');
fragment W: ('W'|'w');
fragment X: ('X'|'x');
fragment Y: ('Y'|'y');
fragment Z: ('Z'|'z');

fragment DIGIT: [0-9];

fragment LETTER: 'a'..'z'| 'A'..'Z' | '_';

// Comment skipping
SINGLE_LINE_COMMENT: '--' ~[\r\n]* -> channel(HIDDEN) ;

MULTILINE_COMMENT : '/*' .*? ( '*/' | EOF ) -> channel(HIDDEN) ;

WS: (' ' ' '* | [ \n\t\r]+) -> channel(HIDDEN) ;

// Lexer rules
NUMBER: (K_PLUS | K_MINUS)? DIGIT DIGIT* (E (K_PLUS | K_MINUS)? DIGIT DIGIT*)? ;

FLOATING_NUMBER: (K_PLUS | K_MINUS)? DIGIT+ K_DOT DIGIT+ (E (K_PLUS | K_MINUS)? DIGIT DIGIT*)? ;

BOOL: K_TRUE | K_FALSE ;

K_COMMA: ',' ;

K_PLUS: '+' ;

K_MINUS: '-' ;

K_STAR: '*' ;

K_DIV: '/' ;

K_DOT: '.' ;

K_LIKE: 'LIKE' ;

K_AND: 'AND' ;

K_OR: 'OR' ;

K_LPAREN: '(' ;

K_LBRACKET: '[' ;

K_RPAREN: ')' ;

K_RBRACKET: ']' ;

K_LT: '<' | 'LT' ;

K_LTE: '<=' | 'LTE' ;

K_EQ: '=' | 'EQ' ;

K_NEQ: '!=' | 'NEQ' ;

K_GT: '>' | 'GT'  ;

K_GTE: '>=' | 'GTE' ;

K_FROM : 'FROM' ;

K_WHERE: 'WHERE' ;

K_ORDERBY: 'ORDERBY' ;

K_GROUPBY: 'GROUPBY' ;

K_LIMIT: 'LIMIT' ;

K_SELECT: 'SELECT' ;

K_MAX: 'MAX' ;

K_MIN: 'MIN' ;

K_SUM: 'SUM' ;

K_COUNT: 'COUNT' ;

K_OFFSET: 'OFFSET' ;

K_AS: 'AS' ;

K_ISA: 'ISA' ;

K_IS: 'IS' ;

K_HAS: 'HAS' ;

K_ASC: 'ASC' ;

K_DESC: 'DESC' ;

K_TRUE: 'TRUE' ;

K_FALSE: 'FALSE' ;

KEYWORD: K_LIKE
        | K_DOT
        | K_SELECT
        | K_AS
        | K_HAS
        | K_IS
        | K_ISA
        | K_WHERE
        | K_LIMIT
        | K_TRUE
        | K_FALSE
        | K_AND
        | K_OR
        | K_GROUPBY
        | K_ORDERBY
        | K_SUM
        | K_MIN
        | K_MAX
        | K_OFFSET
        | K_FROM
        | K_DESC
        | K_ASC
        | K_COUNT
        ;


ID: STRING
    |LETTER (LETTER|DIGIT)*
    | LETTER (LETTER|DIGIT)* KEYWORD KEYWORD*
    | KEYWORD KEYWORD* LETTER (LETTER|DIGIT)*
    | LETTER (LETTER|DIGIT)* KEYWORD KEYWORD* LETTER (LETTER|DIGIT)*
    ;

STRING: '"' ~('"')* '"' | '\'' ~('\'')* '\'' | '`' ~('`')* '`';

