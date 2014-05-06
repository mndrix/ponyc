grammar pony2;

options
{
  output = AST;
  k = 1;
}

// Parser

module
  :  (use | class_ | typedecl)*
  ;

use
  :  'use' STRING ('as' ID)?
  ;

class_
  :  ('actor' | 'class' | 'trait') ID type_params? raw_cap? ('is' types)? member*
  ;

member
  :  ('var' | 'val') ID oftype? (assign seq)? // field
  |  'new' ID type_params? params '?'? body? // constructor
  |  'fun' raw_cap ID type_params? params oftype? '?'? body? // function
  |  'be' ID type_params? params body? // behaviour
  ;

typedecl
  :  'type' ID type_params? (':' type_expr)?
  ;

oftype
  :  ':' type
  ;

types
  :  type (',' type)*
  ;

type
  :  type_expr '^'? // ephemeral types
  ;

type_expr
  :  '(' type_expr (typeop type_expr)* ')' cap? // ADT or tuple
  |  ID ('.' ID)* type_args? cap? // nominal type
  |  '{' fun_type* '}' cap? // structural type
  |  typedecl // nested type definition
  ;

typeop
  :  '|' | '&' | ',' // union, intersection, tuple
  ;

// could make structural types into traits by supplying bodies here
fun_type
  :  'new' ID? type_params? '(' types? ')' '?'?
  |  'fun' raw_cap ID? type_params? '(' types? ')' oftype? '?'?
  |  'be' ID? type_params? '(' types? ')'
  ;

type_params
  :  '[' param (',' param)* ']'
  ;

type_args
  :  '[' type (',' type)* ']'
  ;

cap
  :  raw_cap
  ;

raw_cap
  :  ('iso' | 'trn' | 'mut' | 'imm' | 'box' | 'tag')
  ;

params
  :  '(' (param (',' param)*)? ')'
  ;

param
  :  ID oftype? (assign seq)?
  ;

body
  :  '=>' seq
  ;

seq
  :  expr (';' expr)*
  ;

expr
  :  binary
  |  'return' binary
  |  'break' binary
  |  'continue'
  |  'undef'
  ;

binary
  :  term (binop term)*
  ;

term
  :  local
  |  control
  |  postfix
  |  unop term
  ;

local
  :  ('var' | 'val') idseq oftype?
  ;

control
  :  'if' seq 'then' seq ('elseif' seq 'then' seq)* ('else' seq)? 'end'
  |  'match' seq case* ('else' seq)? 'end'
  |  'while' seq 'do' seq ('else' seq)? 'end'
  |  'do' seq 'while' seq 'end'
  |  'for' idseq oftype? 'in' seq 'do' seq ('else' seq)? 'end'
  |  'try' seq ('else' seq)? ('then' seq)? 'end'
  ;

case
  :  '|' seq? ('as' idseq oftype)? ('where' seq)? body?
  ;

postfix
  :  atom
  (  '.' (ID | INT) // member or tuple component
  |  '!' ID // partial application, syntactic sugar
  |  type_args // type arguments
  |  tuple // method arguments
  )*
  ;

atom
  :  INT
  |  FLOAT
  |  STRING
  |  ID
  |  tuple
  |  array
  |  object
  ;

idseq
  :  ID | '(' ID (',' ID)* ')'
  ;

tuple
  :  '(' positional? named? ')'
  ;

array
  :  '[' positional? named? ']'
  ;

object
  :  '{' ('is' types)? member* '}'
  ;

positional
  :  seq (',' seq)*
  ;

named
  :  'where' term assign seq (',' term assign seq)*
  ;

unop
  :  'not' | '-' | 'consume' | 'recover'
  ;

binop
  :  'and' | 'or' | 'xor' // logic
  |  '+' | '-' | '*' | '/' | '%' // arithmetic
  |  '<<' | '>>' // shift
  |  'is' | '==' | '!=' | '<' | '<=' | '>=' | '>' // comparison
  |  assign
  ;

assign
  :  '='
  ;

/* Precedence?
1. * / %
2. + -
3. << >> // same as C, but confusing?
4. < <= => >
5. == !=
6. and
7. xor
8. or
9. =
*/

// Lexer

ID
  :  (LETTER | '_') (LETTER | DIGIT | '_' | '\'')*
  ;

INT
  :  DIGIT+
  |  '0' 'x' HEX+
  |  '0' 'o' OCTAL+
  |  '0' 'b' BINARY+
  ;

FLOAT
  :  DIGIT+ ('.' DIGIT+)? EXP?
  ;

LINECOMMENT
  :  '//' ~('\n' | '\r')* '\r'? '\n' {$channel=HIDDEN;}
  ;

NESTEDCOMMENT
  :  '/*' ( ('/*') => NESTEDCOMMENT | ~'*' | '*' ~'/')* '*/'
  ;

WS
  :  ' ' | '\t' | '\r' | '\n'
  ;

STRING
  :  '"' ( ESC | ~('\\'|'"') )* '"'
  ;

fragment
EXP
  :  ('e' | 'E') ('+' | '-')? DIGIT+
  ;

fragment
LETTER
  :  'a'..'z' | 'A'..'Z'
  ;

fragment
BINARY
  :  '0'..'1'
  ;

fragment
OCTAL
  :  '0'..'7'
  ;

fragment
DIGIT
  :  '0'..'9'
  ;

fragment
HEX
  :  DIGIT | 'a'..'f' | 'A'..'F'
  ;

fragment
ESC
  :  '\\' ('a' | 'b' | 'f' | 'n' | 'r' | 't' | 'v' | '\"' | '\\' | '0')
  |  HEX_ESC
  |  UNICODE_ESC
  |  UNICODE2_ESC
  ;

fragment
HEX_ESC
  :  '\\' 'x' HEX HEX
  ;

fragment
UNICODE_ESC
  :  '\\' 'u' HEX HEX HEX HEX
  ;

fragment
UNICODE2_ESC
  :  '\\' 'U' HEX HEX HEX HEX HEX HEX
  ;
