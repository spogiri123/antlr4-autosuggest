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

grammar HarmonySQL;

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

  String tableName = "";


}

fromClause : K_FROM tableNames selectClause ;

selectClause: K_SELECT selectExpression whereClause?;

selectExpression: colName((K_COMMA colName)*)?|ASTERISK;

tableNames returns [String value]
@after {
    this.tableName = $value
}
: 'PROFILE_TABLE' | 'REF_TABLE_1' | 'US_DALLAS_CUSTOMERS' | 'US_FORT_WORTH_CUSTOMERS' ;

whereClause: K_WHERE expr ;

colName: {this.tableName == 'PROFILE_TABLE'}? PROFILE_TABLE_COL_NAME
        | {this.tableName == 'REF_TABLE_1'}? REF_TABLE_1_COL_NAME
        ;

expr: compE exprRight* ;

compE: whereColName operator identifier;

whereColName: {this.tableName == 'PROFILE_TABLE'}? PROFILE_TABLE_COL_NAME
        | {this.tableName == 'REF_TABLE_1'}? REF_TABLE_1_COL_NAME
        ;

exprRight: (K_AND | K_OR) compE ;

operator: K_LT | K_LTE | K_EQ | K_NEQ | K_GT | K_GTE | K_LIKE ;

identifier: ID ;

PROFILE_TABLE_COL_NAME: 'FIRST_NAME'|'LAST_NAME';

REF_TABLE_1_COL_NAME: 'REGION'|'STATE';

K_FROM : 'FROM';

K_WHERE : 'WHERE';

K_SELECT: 'SELECT';

K_LIKE: 'LIKE' ;

K_AND: 'AND' ;

K_OR: 'OR' ;

K_LT: '<' | 'LT' ;

K_LTE: '<=' | 'LTE' ;

K_EQ: '=' | 'EQ' ;

K_NEQ: '!=' | 'NEQ' ;

K_GT: '>' | 'GT'  ;

K_GTE: '>=' | 'GTE' ;

K_COMMA: ',';

ASTERISK: '*';

ID: LETTER (LETTER|DIGIT)* ;

fragment DIGIT: [0-9];

fragment LETTER: 'a'..'z'| 'A'..'Z' | '_';

WS
    : [ \r\n\t]+ -> channel(HIDDEN)
    ;

// Catch-all for anything we can't recognize.
// We use this to be able to ignore and recover all the text
// when splitting statements with DelimiterLexer
UNRECOGNIZED
    : .
    ;