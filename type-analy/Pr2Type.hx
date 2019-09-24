// Project Milestone 2 - Type Analysis compiler by HACS.
//
module org.crsx.hacs.Pr2Type {

/* ##################################################
   #    Type Analysis Compiler Implementation       #
   ##################################################
 */

/* LEXICAL ANALYSIS. */

/* Define Space and Comments */
space [ \t\n\r]                                      // white space convention
             | "//"[^\n]*                            // single line comments
             | \/\*([^\*]|\*+[^\*\/])*\*+\/          // multiple line comments
    ;

/* Define keywords */
token IF | if ;
token ELSE | else ;
token WHILE | while ;
token RETURN | return ;
token VAR | var ;
token NULL | null ;
token SIZEOF | sizeof ;
token FUNC | function ;

/* Define String, Integers and Identifier */
token INT    | ⟨Digit⟩+ ;                                                  // integer
token STRING | \" ( [^\"\n\\] | \\ ⟨Following⟩ )* \" ;                     // string
token ID | ( ⟨Letter⟩ | '$' | '_' ) ( ⟨Letter⟩ | ⟨Digit⟩ | '$' | '_' )* ;  // identifier

/* Useful Token Fragment */
token fragment Digit  | [0-9] ;
token fragment Letter  | [a-zA-Z] ;
token fragment Following 
      | \n 
      | [\\\"]
      | [nt] 
      | [0-7]? [0-7]? [0-7]          // octal digits
      | x [0-9A-F] [0-9A-F]          // hexadecimal digits
;

/* SYNTAX ANALYSIS. */

/* Define Expression */
sort Exp   | ⟦ ⟨Exp@2⟩ || ⟨Exp@1⟩ ⟧@1           // logical or
           | ⟦ ⟨Exp@3⟩ && ⟨Exp@2⟩ ⟧@2           // logical and

           | ⟦ ⟨Exp@4⟩ == ⟨Exp@4⟩ ⟧@3           // comparison equal
           | ⟦ ⟨Exp@4⟩ != ⟨Exp@4⟩ ⟧@3           // comparison not equal

           | ⟦ ⟨Exp@5⟩ < ⟨Exp@5⟩ ⟧@4            // comparison smaller
           | ⟦ ⟨Exp@5⟩ > ⟨Exp@5⟩ ⟧@4            // comparison greater
           | ⟦ ⟨Exp@5⟩ <= ⟨Exp@5⟩ ⟧@4           // comparison smaller and equal
           | ⟦ ⟨Exp@5⟩ >= ⟨Exp@5⟩ ⟧@4           // comparison greater and equal

           | ⟦ ⟨Exp@5⟩ + ⟨Exp@6⟩ ⟧@5            // addition
           | ⟦ ⟨Exp@5⟩ - ⟨Exp@6⟩ ⟧@5            // subtraction

           | ⟦ ⟨Exp@6⟩ * ⟨Exp@7⟩ ⟧@6            // multiplication
           | ⟦ ⟨Exp@6⟩ / ⟨Exp@7⟩ ⟧@6            // division
           | ⟦ ⟨Exp@6⟩ % ⟨Exp@7⟩ ⟧@6            // modular

           | ⟦ ! ⟨Exp@7⟩ ⟧@7                    // not sign
           | ⟦ - ⟨Exp@7⟩ ⟧@7                    // negative sign
           | ⟦ + ⟨Exp@7⟩ ⟧@7                    // positive sign
           | ⟦ * ⟨Exp@7⟩ ⟧@7                    // pointer dereference
           | ⟦ & ⟨Exp@7⟩ ⟧@7                    // address reference

           | ⟦ ⟨Exp@8⟩ ( ⟨Exps⟩ ) ⟧@8
           | ⟦ ⟨NULL⟩ ( ⟨Type⟩ ) ⟧@8
           | ⟦ ⟨SIZEOF⟩ ( ⟨Type⟩ ) ⟧@8

           | ⟦ ⟨INT⟩ ⟧@9                        // integer
           | ⟦ ⟨STRING⟩ ⟧@9                     // string
           | ⟦ ⟨ID⟩ ⟧@9                         // identifier
           | sugar ⟦ (⟨Exp#⟩) ⟧@9 → Exp#        // parenthesis
           ;

sort Exps | ⟦ ⟨Exp⟩ , ⟨Exps⟩ ⟧       // more expressions
          | ⟦ ⟨Exp⟩ ⟧                // one expressions
          | ⟦⟧                       // zero expressions
    ;

/* Define Lvalue for Statement */
sort Lval | ⟦ ⟨ID⟩ ⟧
          | ⟦ * ⟨Exp⟩ ⟧
    ;

/* Define Type */
sort Type | ⟦ int ⟧@3 
          | ⟦ char ⟧@3 
          | sugar ⟦ (⟨Type#⟩) ⟧@3 → Type# 
          | ⟦ ⟨Type@2⟩ ( ⟨Types⟩ ) ⟧@2
          | ⟦ * ⟨Type@1⟩ ⟧@1
    ;

sort Types | ⟦ ⟨Type⟩ , ⟨Types⟩ ⟧
           | ⟦ ⟨Type⟩ ⟧
           | ⟦⟧
    ;


sort Type | scheme Bool(Type);  // scheme to check either type is int or pointer
Bool(⟦ int ⟧) → ⟦ int ⟧ ;
Bool(⟦ * ⟨Type#1⟩ ⟧) → ⟦ * ⟨Type#1⟩ ⟧ ;
default Bool(#t) → error ⟦ expected given type of int (Boolean) ⟧ ;

sort Type | scheme Star(Type); // scheme to check the type is a pointer
Star(⟦ * ⟨Type#1⟩ ⟧) → ⟦ ⟨Type#1⟩ ⟧;
default Star(#t) → error ⟦ type could not be dereferenced ⟧ ;

sort Type | scheme CheckInt(Type, Type);  // scheme to check two types are int or not
CheckInt(⟦ int ⟧, ⟦ int ⟧) → ⟦ int ⟧;
default CheckInt(#t1, #t2) → error ⟦ expected int for binary operator ⟧ ;

sort Type | scheme LogicCheck(Type, Type); // scheme for type checking of logical operator
LogicCheck(⟦ int ⟧, ⟦ int ⟧) → ⟦ int ⟧;
LogicCheck(⟦ int ⟧, ⟦ * ⟨Type#1⟩ ⟧) → ⟦ int ⟧;
LogicCheck(⟦ * ⟨Type#1⟩ ⟧, ⟦ int ⟧) → ⟦ int ⟧;
LogicCheck(⟦ * ⟨Type#1⟩ ⟧, ⟦ * ⟨Type#2⟩ ⟧) → ⟦ int ⟧;
default LogicCheck(#t1, #t2) → error ⟦ expected int or pointer ⟧ ;

sort Type | scheme CheckTypeSame(Type, Type); // scheme for assignment operator
CheckTypeSame(#t1, #t1) → #t1;
default CheckTypeSame(#t1, #t2) → error ⟦ expected two same types for assignment ⟧ ;

sort Type | scheme CheckEqual(Type, Type); // scheme for == or !=
CheckEqual(⟦ int ⟧, ⟦ int ⟧) → ⟦ int ⟧;
CheckEqual(⟦ * ⟨Type#1⟩ ⟧, ⟦ * ⟨Type#1⟩ ⟧) → ⟦ int ⟧;
CheckEqual(#t1, #t2) → error ⟦ expected two same types for equal or not ⟧ ;

sort Type | scheme CheckReturnType(Type, Type); // scheme for checking return type
CheckReturnType(⟦ ⟨Type#1⟩ ⟧, ⟦ ⟨Type#1⟩ ⟧) → ⟦ ⟨Type#1⟩ ⟧;
default CheckReturnType(#t1, #t2) → error ⟦ return type should be same as declared ⟧ ;

sort Type | scheme LeftOp(Type, Type); // scheme for + and - operator
LeftOp(⟦ int ⟧, ⟦ int ⟧) → ⟦ int ⟧;
LeftOp(⟦ * ⟨Type#1⟩ ⟧, ⟦ int ⟧) → ⟦ * ⟨Type#1⟩ ⟧;
LeftOp(#t1, #t2) → error ⟦ expected int or left pointer for plus or minus ⟧ ;

sort Type | scheme AddStar(Type); // scheme for & operator
AddStar(⟦ ⟨Type#1⟩ ⟧) → ⟦ * ⟨Type#1⟩ ⟧ ;

sort Type | scheme CheckExps(Type, Types); // scheme to check type and types of expressions
CheckExps(⟦ ⟨Type#1⟩ ( ⟨Types#2⟩ ) ⟧, ⟦ ⟨Types#2⟩ ⟧) → ⟦ ⟨Type#1⟩ ⟧ ;
default CheckExps(#t1, #t2) → error ⟦ expected argument types same ⟧ ;


sort Type | scheme CheckMain(Type); // scheme to check type of main function
CheckMain(⟦ int ( ⟨Types#t2⟩ ) ⟧) → ⟦ int ( ⟨Types CheckChars(#t2)⟩ ) ⟧;
default CheckMain(#t1) → error ⟦ main function must have return type int ⟧ ;

sort Types | scheme CheckChars(Types); // helper scheme to check type of main function
CheckChars(⟦ ⟨Type ⟦ * char ⟧⟩ , ⟨Types #t2⟩ ⟧) → ⟦ ⟨Type ⟦ * char ⟧⟩ , ⟨Types CheckChars(#t2)⟩ ⟧;
CheckChars(⟦ ⟨Type ⟦ * char ⟧⟩ ⟧) → ⟦ * char ⟧;
CheckChars(⟦ ⟧) → ⟦ ⟧;
default CheckChars(#t1) → error ⟦ main function must have only parameters of type *char ⟧ ;

/* Define Statement */
sort Stat | ⟦ ⟨VAR⟩ ⟨Type⟩ ⟨ID⟩ ; ⟧
          | ⟦ ⟨Lval⟩ = ⟨Exp⟩ ; ⟧
          | ⟦ ⟨IF⟩ ( ⟨Exp⟩ ) ⟨Stat⟩ ⟨IfTail⟩ ⟧
          | ⟦ ⟨WHILE⟩ ( ⟨Exp⟩ ) ⟨Stat⟩ ⟧
          | ⟦ ⟨RETURN⟩ ⟨Exp⟩; ⟧
          | ⟦ { ⟨Stats⟩ } ⟧
    ;

/* Define IfTail for if statement */
sort IfTail | ⟦ ⟨ELSE⟩ ⟨Stat⟩ ⟧
            | ⟦⟧
    ;

sort Stats | ⟦ ⟨Stat⟩ ⟨Stats⟩ ⟧
           | ⟦⟧
    ;

/* Define Declaration */
sort Declar | ⟦ ⟨FUNC⟩ ⟨Type⟩ ⟨ID⟩ ( ⟨Param⟩ ) { ⟨Stats⟩ } ⟧ ;

sort Param  | ⟦ ⟨Type⟩ ⟨ID⟩ , ⟨Param⟩ ⟧
            | ⟦ ⟨Type⟩ ⟨ID⟩ ⟧
            | ⟦⟧
    ;

sort Declars | ⟦ ⟨Declar⟩ ⟨Declars⟩ ⟧
             | ⟦ ⟨Declar⟩ ⟧
    ;

/* Define Program */
sort Program |  ⟦ ⟨Declars⟩ ⟧ ;

/* SEMANTIC ANALYSIS. */

attribute ↑t(Type);  // synthesized type
attribute ↓e{ID:Type};  // inherited type environment

/***** Define synthesized ↑t for expression *****/
sort Exp | ↑t;

⟦ ⟨INT#⟩ ⟧ ↑t(⟦ int ⟧); // An Integer constant has type int
⟦ ⟨STRING#⟩ ⟧ ↑t(⟦ * char ⟧); // A string constant has type *char
// Variable ↑t will be populated by Env

⟦ ⟨NULL#1⟩ ( ⟨Type#2⟩ ) ⟧ ↑t(#2);
⟦ ⟨SIZEOF#1⟩ ( ⟨Type#2⟩ ) ⟧ ↑t(⟦ int ⟧);
⟦ ⟨Exp#1 ↑t(#t1)⟩ ( ⟨Exps#2 ↑ts(#t2)⟩ ) ⟧↑t(CheckExps(#t1,#t2));

⟦ ! ⟨Exp#1 ↑t(#t1)⟩ ⟧ ↑t(Bool(#t1));
⟦ - ⟨Exp#1 ↑t(#t1)⟩ ⟧ ↑t(Bool(#t1));
⟦ + ⟨Exp#1 ↑t(#t1)⟩ ⟧ ↑t(Bool(#t1));
⟦ * ⟨Exp#1 ↑t(#t1)⟩ ⟧ ↑t(Star(#t1)); // check E must have type *T
⟦ & ⟨Exp#1 ↑t(#t1)⟩ ⟧ ↑t(AddStar(#t1)); // E has type *T

⟦ ⟨Exp#1 ↑t(#t1)⟩ * ⟨Exp#2 ↑t(#t2)⟩ ⟧ ↑t(CheckInt(#t1, #t2));
⟦ ⟨Exp#1 ↑t(#t1)⟩ / ⟨Exp#2 ↑t(#t2)⟩ ⟧ ↑t(CheckInt(#t1, #t2));
⟦ ⟨Exp#1 ↑t(#t1)⟩ % ⟨Exp#2 ↑t(#t2)⟩ ⟧ ↑t(CheckInt(#t1, #t2));

⟦ ⟨Exp#1 ↑t(#t1)⟩ + ⟨Exp#2 ↑t(#t2)⟩ ⟧ ↑t(LeftOp(#t1, #t2));
⟦ ⟨Exp#1 ↑t(#t1)⟩ - ⟨Exp#2 ↑t(#t2)⟩ ⟧ ↑t(LeftOp(#t1, #t2));

⟦ ⟨Exp#1 ↑t(#t1)⟩ < ⟨Exp#2 ↑t(#t2)⟩ ⟧ ↑t(CheckInt(#t1, #t2));
⟦ ⟨Exp#1 ↑t(#t1)⟩ > ⟨Exp#2 ↑t(#t2)⟩ ⟧ ↑t(CheckInt(#t1, #t2));
⟦ ⟨Exp#1 ↑t(#t1)⟩ <= ⟨Exp#2 ↑t(#t2)⟩ ⟧ ↑t(CheckInt(#t1, #t2));
⟦ ⟨Exp#1 ↑t(#t1)⟩ >= ⟨Exp#2 ↑t(#t2)⟩ ⟧ ↑t(CheckInt(#t1, #t2));

⟦ ⟨Exp#1 ↑t(#t1)⟩ == ⟨Exp#2 ↑t(#t2)⟩ ⟧ ↑t(CheckEqual(#t1, #t2));
⟦ ⟨Exp#1 ↑t(#t1)⟩ != ⟨Exp#2 ↑t(#t2)⟩ ⟧ ↑t(CheckEqual(#t1, #t2));

⟦ ⟨Exp#1 ↑t(#t1)⟩ || ⟨Exp#2 ↑t(#t2)⟩ ⟧ ↑t(LogicCheck(#t1, #t2));
⟦ ⟨Exp#1 ↑t(#t1)⟩ && ⟨Exp#2 ↑t(#t2)⟩ ⟧ ↑t(LogicCheck(#t1, #t2));

/***** Define scheme for inherited ↓e of expression *****/

sort Exp | scheme Env(Exp) ↓e;
Env(⟦ ⟨INT#⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ ⟨INT#⟩ ⟧ ↑#syn;
Env(⟦ ⟨STRING#⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ ⟨STRING#⟩ ⟧ ↑#syn;
Env(⟦ ⟨ID#1⟩ ⟧)↓e{#1 : #t} → ⟦ ⟨ID#1⟩ ⟧ ↑t(#t);

Env(⟦ ⟨NULL#1⟩ ( ⟨Type#2⟩ ) ⟧↑#syn)↓e{:#Ee} → ⟦ ⟨NULL#1⟩ ( ⟨Type#2⟩ ) ⟧↑#syn;
Env(⟦ ⟨SIZEOF#1⟩ ( ⟨Type#2⟩ ) ⟧↑#syn)↓e{:#Ee} → ⟦ ⟨SIZEOF#1⟩ ( ⟨Type#2⟩ ) ⟧↑#syn;
Env(⟦ ⟨Exp#1⟩ ( ⟨Exps#2⟩ ) ⟧↑#syn)↓e{:#Ee} → HelperExp(⟦ ⟨Exp Env(#1)↓e{:#Ee}⟩ ( ⟨Exps EnvE(#2)↓e{:#Ee}⟩ ) ⟧↑#syn); // evaluated exp and exps firstly and then check types same
{
  | scheme HelperExp(Exp);
  HelperExp(⟦ ⟨Exp#1 ↑t(#t1)⟩ ( ⟨Exps#2 ↑ts(#t2)⟩ ) ⟧) → ⟦ ⟨Exp#1⟩ ( ⟨Exps#2⟩ ) ⟧↑t(CheckExps(#t1,#t2));
}

Env(⟦ ! ⟨Exp#1⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ ! ⟨Exp Env(#1)↓e{:#Ee}⟩ ⟧↑#syn;
Env(⟦ - ⟨Exp#1⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ - ⟨Exp Env(#1)↓e{:#Ee}⟩ ⟧↑#syn;
Env(⟦ + ⟨Exp#1⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ + ⟨Exp Env(#1)↓e{:#Ee}⟩ ⟧↑#syn;
Env(⟦ * ⟨Exp#1⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ * ⟨Exp Env(#1)↓e{:#Ee}⟩ ⟧↑#syn;
Env(⟦ & ⟨Exp#1⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ & ⟨Exp Env(#1)↓e{:#Ee}⟩ ⟧↑#syn;

Env(⟦ ⟨Exp#1⟩ * ⟨Exp#2⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ ⟨Exp Env(#1)↓e{:#Ee}⟩ * ⟨Exp Env(#2)↓e{:#Ee}⟩ ⟧↑#syn;
Env(⟦ ⟨Exp#1⟩ / ⟨Exp#2⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ ⟨Exp Env(#1)↓e{:#Ee}⟩ / ⟨Exp Env(#2)↓e{:#Ee}⟩ ⟧↑#syn;
Env(⟦ ⟨Exp#1⟩ % ⟨Exp#2⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ ⟨Exp Env(#1)↓e{:#Ee}⟩ % ⟨Exp Env(#2)↓e{:#Ee}⟩ ⟧↑#syn;

Env(⟦ ⟨Exp#1⟩ + ⟨Exp#2⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ ⟨Exp Env(#1)↓e{:#Ee}⟩ + ⟨Exp Env(#2)↓e{:#Ee}⟩ ⟧↑#syn;
Env(⟦ ⟨Exp#1⟩ - ⟨Exp#2⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ ⟨Exp Env(#1)↓e{:#Ee}⟩ - ⟨Exp Env(#2)↓e{:#Ee}⟩ ⟧↑#syn;

Env(⟦ ⟨Exp#1⟩ < ⟨Exp#2⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ ⟨Exp Env(#1)↓e{:#Ee}⟩ < ⟨Exp Env(#2)↓e{:#Ee}⟩ ⟧↑#syn;
Env(⟦ ⟨Exp#1⟩ > ⟨Exp#2⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ ⟨Exp Env(#1)↓e{:#Ee}⟩ > ⟨Exp Env(#2)↓e{:#Ee}⟩ ⟧↑#syn;
Env(⟦ ⟨Exp#1⟩ <= ⟨Exp#2⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ ⟨Exp Env(#1)↓e{:#Ee}⟩ <= ⟨Exp Env(#2)↓e{:#Ee}⟩ ⟧↑#syn;
Env(⟦ ⟨Exp#1⟩ >= ⟨Exp#2⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ ⟨Exp Env(#1)↓e{:#Ee}⟩ >= ⟨Exp Env(#2)↓e{:#Ee}⟩ ⟧↑#syn;

Env(⟦ ⟨Exp#1⟩ == ⟨Exp#2⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ ⟨Exp Env(#1)↓e{:#Ee}⟩ == ⟨Exp Env(#2)↓e{:#Ee}⟩ ⟧↑#syn;
Env(⟦ ⟨Exp#1⟩ != ⟨Exp#2⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ ⟨Exp Env(#1)↓e{:#Ee}⟩ != ⟨Exp Env(#2)↓e{:#Ee}⟩ ⟧↑#syn;

Env(⟦ ⟨Exp#1⟩ || ⟨Exp#2⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ ⟨Exp Env(#1)↓e{:#Ee}⟩ || ⟨Exp Env(#2)↓e{:#Ee}⟩ ⟧↑#syn;
Env(⟦ ⟨Exp#1⟩ && ⟨Exp#2⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ ⟨Exp Env(#1)↓e{:#Ee}⟩ && ⟨Exp Env(#2)↓e{:#Ee}⟩ ⟧↑#syn;

/***** Define synthesized ↑ts for expressions *****/

attribute ↑ts(Types); // synthesized types

sort Exps | ↑ts;
⟦  ⟧↑ts(⟦  ⟧);

/***** Define scheme for inherited ↓e of expressions *****/

sort Exps | scheme EnvE(Exps) ↓e;
EnvE(⟦ ⟨Exp#1⟩ , ⟨Exps#2⟩ ⟧↑#syn)↓e{:#Ee} → Temp1(⟦ ⟨Exp Env(#1)↓e{:#Ee}⟩ , ⟨Exps EnvE(#2)↓e{:#Ee}⟩ ⟧↑#syn);
{
  | scheme Temp1(Exps);
  Temp1(⟦ ⟨Exp#1 ↑t(#t1)⟩ , ⟨Exps#2 ↑ts(#t2)⟩ ⟧) → ⟦ ⟨Exp#1⟩ , ⟨Exps#2⟩ ⟧↑ts(⟦ ⟨Type #t1⟩ , ⟨Types #t2⟩ ⟧);
}
EnvE(⟦ ⟨Exp#1⟩ ⟧↑#syn)↓e{:#Ee} → TempO(⟦ ⟨Exp Env(#1)↓e{:#Ee}⟩ ⟧↑#syn);
{
  | scheme TempO(Exps);
  TempO(⟦ ⟨Exp#1 ↑t(#t1)⟩ ⟧)  → ⟦ ⟨Exp#1⟩ ⟧↑ts(⟦ ⟨Type #t1⟩ ⟧);
}
EnvE(⟦  ⟧↑#syn) → ⟦  ⟧↑#syn;

/***** Define scheme for inherited ↓rt ↓e of statement *****/

attribute ↓rt(Type); // inherited return type

sort Stat | scheme EnvS(Stat) ↓e ↓rt;
EnvS(⟦ ⟨VAR#1⟩ ⟨Type#2⟩ ⟨ID#3⟩ ; ⟧↑#syn)↓e{:#Ee}↓rt(#Rt) → ⟦ ⟨VAR#1⟩ ⟨Type#2⟩ ⟨ID#3⟩ ; ⟧↑#syn ;
EnvS(⟦ ⟨Lval#1⟩ = ⟨Exp#2⟩ ; ⟧↑#syn)↓e{:#Ee}↓rt(#Rt) → HelperAS(⟦ ⟨Lval EnvL(#1)↓e{:#Ee}⟩ = ⟨Exp Env(#2)↓e{:#Ee}⟩ ; ⟧↑#syn);
{
  | scheme HelperAS(Stat);
  HelperAS(⟦ ⟨Lval#1 ↑t(#t1)⟩ = ⟨Exp#2 ↑t(#t2)⟩ ; ⟧↑#syn) → ⟦ ⟨Lval#1⟩ = ⟨Exp#2⟩ ; ⟧↑t(CheckTypeSame(#t1, #t2))↑#syn;
}
EnvS(⟦ ⟨IF#1⟩ ( ⟨Exp#2⟩ ) ⟨Stat#3⟩ ⟨IfTail#4⟩ ⟧↑#syn)↓e{:#Ee}↓rt(#Rt) →
  HelperIfS(⟦ ⟨IF#1⟩ ( ⟨Exp Env(#2)↓e{:#Ee}⟩ ) ⟨Stat#3⟩ ⟨IfTail#4⟩ ⟧↑#syn)↓e{:#Ee}↓rt(#Rt);
{
  | scheme HelperIfS(Stat) ↓e ↓rt;
  HelperIfS(⟦ ⟨IF#1⟩ ( ⟨Exp#2 ↑t(#t)⟩ ) ⟨Stat#3⟩ ⟨IfTail#4⟩ ⟧↑#syn)↓e{:#Ee}↓rt(#Rt) → ⟦ ⟨IF#1⟩ ( ⟨Exp#2⟩ ) ⟨Stat EnvS(#3)↓e{:#Ee}↓rt(#Rt)⟩ ⟨IfTail EnvIf(#4)↓e{:#Ee}↓rt(#Rt)⟩ ⟧ ↑t(Bool(#t))↑#syn;
}
EnvS(⟦ ⟨WHILE#1⟩ ( ⟨Exp#2⟩ ) ⟨Stat#3⟩ ⟧↑#syn)↓e{:#Ee}↓rt(#Rt) → 
  HelperWhS(⟦ ⟨WHILE#1⟩ ( ⟨Exp Env(#2)↓e{:#Ee}⟩ ) ⟨Stat#3⟩ ⟧↑#syn)↓e{:#Ee}↓rt(#Rt);
{
  | scheme HelperWhS(Stat) ↓e ↓rt;
  HelperWhS(⟦ ⟨WHILE#1⟩ ( ⟨Exp#2 ↑t(#t)⟩ ) ⟨Stat#3⟩ ⟧↑#syn)↓e{:#Ee}↓rt(#Rt) → 
  ⟦ ⟨WHILE#1⟩ ( ⟨Exp#2⟩ ) ⟨Stat EnvS(#3)↓e{:#Ee}↓rt(#Rt)⟩ ⟧ ↑t(Bool(#t))↑#syn;
}
EnvS(⟦ ⟨RETURN#1⟩ ⟨Exp#2⟩ ; ⟧↑#syn)↓e{:#Ee}↓rt(#Rt) → HelperReS(⟦ ⟨RETURN#1⟩ ⟨Exp Env(#2)↓e{:#Ee}⟩; ⟧↑#syn)↓e{:#Ee}↓rt(#Rt);
{
  | scheme HelperReS(Stat) ↓e ↓rt;
  HelperReS(⟦ ⟨RETURN#1⟩ ⟨Exp#2 ↑t(#t)⟩ ; ⟧↑#syn)↓e{:#Ee}↓rt(#Rt) → ⟦ ⟨RETURN#1⟩ ⟨Exp#2⟩;⟧ ↑t(CheckReturnType(#t, #Rt)) ↑#syn;
}
EnvS(⟦ { ⟨Stats#1⟩ } ⟧↑#syn)↓e{:#Ee}↓rt(#Rt) → ⟦ { ⟨Stats EnvSS(#1)↓e{:#Ee}↓rt(#Rt)⟩ } ⟧↑#syn ;

/***** Define scheme for inherited ↓rt ↓e of if-tail-statement *****/

sort IfTail | scheme EnvIf(IfTail) ↓e ↓rt;
EnvIf(⟦ ⟨ELSE#1⟩ ⟨Stat#2⟩ ⟧↑#syn)↓e{:#Ee}↓rt(#Rt) → ⟦ ⟨ELSE#1⟩ ⟨Stat EnvS(#2)↓e{:#Ee}↓rt(#Rt)⟩ ⟧↑#syn;
EnvIf(⟦ ⟧↑#syn) → ⟦⟧↑#syn;

/***** Define synthesized ↑t for left assignment *****/

sort Lval | ↑t;
⟦ * ⟨Exp#1 ↑t(#t1)⟩ ⟧ ↑t(Star(#t1));

/***** Define scheme for inherited ↓e of left assignment *****/

sort Lval | scheme EnvL(Lval)↓e;
EnvL(⟦ ⟨ID#1⟩ ⟧)↓e{#1 : #t} → ⟦ ⟨ID#1⟩ ⟧↑t(#t);
EnvL(⟦ * ⟨Exp#1⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ * ⟨Exp Env(#1)↓e{:#Ee}⟩ ⟧↑#syn;

/***** Define scheme for inherited ↓rt ↓e of statements *****/

sort Stats | scheme EnvSS(Stats) ↓e ↓rt;
EnvSS(⟦ ⟨VAR#1⟩ ⟨Type#2⟩ ⟨ID#3⟩ ; ⟨Stats#4⟩ ⟧↑#syn)↓e{:#Ee}↓rt(#Rt) → ⟦ ⟨VAR#1⟩ ⟨Type#2⟩ ⟨ID#3⟩ ; ⟨Stats EnvSS(#4)↓e{:#Ee}↓e{#3:#2}↓rt(#Rt)⟩ ⟧↑#syn;

EnvSS(⟦ ⟨Lval#1⟩ = ⟨Exp#2⟩ ; ⟨Stats#3⟩ ⟧↑#syn)↓e{:#Ee}↓rt(#Rt) → Helper(⟦ ⟨Lval EnvL(#1)↓e{:#Ee}⟩ = ⟨Exp Env(#2)↓e{:#Ee}⟩ ; ⟨Stats#3⟩ ⟧↑#syn)↓e{:#Ee}↓rt(#Rt);
{
  | scheme Helper(Stats) ↓e ↓rt;
  Helper(⟦ ⟨Lval#1 ↑t(#t1)⟩ = ⟨Exp#2 ↑t(#t2)⟩ ; ⟨Stats#3⟩ ⟧↑#syn)↓e{:#Ee}↓rt(#Rt) → ⟦ ⟨Lval#1⟩ = ⟨Exp#2⟩ ; ⟨Stats EnvSS(#3)↓e{:#Ee}↓rt(#Rt)⟩ ⟧↑t(CheckTypeSame(#t1, #t2)) ↑#syn;
}

EnvSS(⟦ ⟨IF#1⟩ ( ⟨Exp#2⟩ ) ⟨Stat#3⟩ ⟨IfTail#4⟩ ⟨Stats#5⟩ ⟧↑#syn)↓e{:#Ee}↓rt(#Rt) →
  HelperIf(⟦ ⟨IF#1⟩ ( ⟨Exp Env(#2)↓e{:#Ee}⟩ ) ⟨Stat#3⟩ ⟨IfTail#4⟩ ⟨Stats#5⟩ ⟧↑#syn)↓e{:#Ee}↓rt(#Rt);
{
  | scheme HelperIf(Stats) ↓e ↓rt;
  HelperIf(⟦ ⟨IF#1⟩ ( ⟨Exp#2 ↑t(#t)⟩ ) ⟨Stat#3⟩ ⟨IfTail#4⟩ ⟨Stats#5⟩ ⟧↑#syn)↓e{:#Ee}↓rt(#Rt) → ⟦ ⟨IF#1⟩ ( ⟨Exp#2⟩ ) ⟨Stat EnvS(#3)↓e{:#Ee}↓rt(#Rt)⟩ ⟨IfTail EnvIf(#4)↓e{:#Ee}↓rt(#Rt)⟩ ⟨Stats EnvSS(#5)↓e{:#Ee}↓rt(#Rt)⟩ ⟧ ↑t(Bool(#t))↑#syn;
}

EnvSS(⟦ ⟨WHILE#1⟩ ( ⟨Exp#2⟩ ) ⟨Stat#3⟩ ⟨Stats#4⟩⟧↑#syn)↓e{:#Ee}↓rt(#Rt) → 
  HelperWh(⟦ ⟨WHILE#1⟩ ( ⟨Exp Env(#2)↓e{:#Ee}⟩ ) ⟨Stat#3⟩ ⟨Stats#4⟩⟧↑#syn)↓e{:#Ee}↓rt(#Rt);
{
  | scheme HelperWh(Stats) ↓e ↓rt;
  HelperWh(⟦ ⟨WHILE#1⟩ ( ⟨Exp#2 ↑t(#t)⟩ ) ⟨Stat#3⟩ ⟨Stats#4⟩⟧↑#syn)↓e{:#Ee}↓rt(#Rt) → 
  ⟦ ⟨WHILE#1⟩ ( ⟨Exp#2⟩ ) ⟨Stat EnvS(#3)↓e{:#Ee}↓rt(#Rt)⟩ ⟨Stats EnvSS(#4)↓e{:#Ee}↓rt(#Rt)⟩⟧ ↑t(Bool(#t))↑#syn;
}
EnvSS(⟦ ⟨RETURN#1⟩ ⟨Exp#2⟩ ; ⟨Stats#3⟩⟧↑#syn)↓e{:#Ee}↓rt(#Rt) → HelperRe(⟦ ⟨RETURN#1⟩ ⟨Exp Env(#2)↓e{:#Ee}⟩; ⟨Stats#3⟩⟧↑#syn)↓e{:#Ee}↓rt(#Rt);
{
  | scheme HelperRe(Stats) ↓e ↓rt;
  HelperRe(⟦ ⟨RETURN#1⟩ ⟨Exp#2 ↑t(#t)⟩ ; ⟨Stats#3⟩⟧↑#syn)↓e{:#Ee}↓rt(#Rt) → ⟦ ⟨RETURN#1⟩ ⟨Exp#2⟩; ⟨Stats EnvSS(#3)↓e{:#Ee}↓rt(#Rt)⟩⟧ ↑t(CheckReturnType(#t, #Rt)) ↑#syn;
}
EnvSS(⟦ { ⟨Stats#1⟩ } ⟨Stats#2⟩⟧↑#syn)↓e{:#Ee}↓rt(#Rt) → ⟦ { ⟨Stats EnvSS(#1)↓e{:#Ee}↓rt(#Rt)⟩ } ⟨Stats EnvSS(#2)↓e{:#Ee}↓rt(#Rt)⟩⟧↑#syn;
EnvSS(⟦⟧↑#syn) → ⟦⟧↑#syn;

/***** Define an FDAttr sort to record type and ID for parameters or function *****/

sort FDAttr | NoAttr | Attr(ID, Type, FDAttr) ;
  | scheme AppendAttr(FDAttr, FDAttr);
  AppendAttr(NoAttr, #) → # ;
  AppendAttr(Attr(#ID, #T, #1), #2) → Attr(#ID, #T, AppendAttr(#1, #2)) ; 
  | scheme AttrExtendSS(Stats, FDAttr) ↓e ↓rt; // scheme to extend type of parameters
  AttrExtendSS(#1, NoAttr) ↓e{:#e} ↓rt(#Rt)→ EnvSS(#1) ↓e{:#e} ↓rt(#Rt);
  AttrExtendSS(#1, Attr(#ID, #T, #2)) ↓e{:#e}↓rt(#Rt) → AttrExtendSS(#1, #2) ↓e{:#e}↓e{#ID : #T} ↓rt(#Rt);

/***** Define synthesized ↑fd for parameter *****/

attribute ↑fd(FDAttr); // syntesized function or parameter declaration

sort Param | ↑fd;
⟦ ⟨Type#1⟩ ⟨ID#2⟩ , ⟨Param#3 ↑fd(#f)⟩ ⟧↑fd(Attr(#2,#1,#f));
⟦ ⟨Type#1⟩ ⟨ID#2⟩ ⟧↑fd(Attr(#2,#1,NoAttr));
⟦⟧↑fd(NoAttr);

/***** Define synthesized ↑tl for parameter *****/

attribute ↑tl(Types); // syntesized parameter types

sort Param | ↑tl;
⟦ ⟨Type#1⟩ ⟨ID#2⟩ , ⟨Param#3 ↑tl(#t)⟩ ⟧↑tl(⟦ ⟨Type#1⟩ , ⟨Types#t⟩ ⟧);
⟦ ⟨Type#1⟩ ⟨ID#2⟩ ⟧↑tl(⟦ ⟨Type#1⟩ ⟧);
⟦⟧↑tl(⟦ ⟧);

/***** Define synthesized ↑fd for declaration *****/

sort Declar | ↑fd;
⟦ ⟨FUNC#1⟩ ⟨Type#2⟩ ⟨ID#3⟩ ( ⟨Param#4 ↑tl(#t)⟩ ) { ⟨Stats#5⟩ } ⟧↑fd(Attr(#3, ⟦ ⟨Type#2⟩ ( ⟨Types#t⟩ ) ⟧, NoAttr));

/***** Define scheme for inherited ↓e of declaration *****/

sort Declar | scheme EnvD(Declar) ↓e;
EnvD(⟦ ⟨FUNC#1⟩ ⟨Type#2⟩ ⟨ID#3⟩ ( ⟨Param#4 ↑fd(#f)⟩ ) { ⟨Stats#5⟩ } ⟧↑#syn)↓e{:#Ee} → ⟦ ⟨FUNC#1⟩ ⟨Type#2⟩ ⟨ID#3⟩ ( ⟨Param#4⟩ ) { ⟨Stats AttrExtendSS(#5, #f)↓e{:#Ee}↓rt(#2)⟩ } ⟧ ↑#syn;

/***** Define synthesized ↑fd for declarations *****/

sort Declars | ↑fd;
⟦ ⟨Declar#1 ↑fd(#d1)⟩ ⟨Declars#2 ↑fd(#d2)⟩ ⟧ ↑fd(AppendAttr(#d1, #d2));
⟦ ⟨Declar#1 ↑fd(#d1)⟩ ⟧ ↑fd(#d1);

/***** Define scheme for inherited ↓e of declarations *****/

sort Declars | scheme EnvDS(Declars) ↓e;
EnvDS(⟦ ⟨Declar#1⟩ ⟨Declars#2⟩⟧↑#syn)↓e{:#Ee} → ⟦ ⟨Declar EnvD(#1)↓e{:#Ee}⟩ ⟨Declars EnvDS(#2)↓e{:#Ee}⟩⟧ ↑#syn;
EnvDS(⟦ ⟨Declar#1⟩ ⟧↑#syn)↓e{:#Ee} → ⟦ ⟨Declar EnvD(#1)↓e{:#Ee}⟩ ⟧ ↑#syn;

/***** Define an IDS sort to record the name of each function *****/

sort IDS | Cons(ID, IDS) | Nil;

| scheme MatchID(ID, IDS); // scheme for cheking whether an ID is used or not
MatchID(#d, Nil) → Cons(#d, Nil); // if not matching, add it into IDS
[data #d] MatchID(#d, Cons(#d, #ds)) → error ⟦ function name only declared once ⟧ ;
default MatchID(#d, Cons(#d2, #ds)) → Cons(#d2, MatchID(#d, #ds)) ;

sort FDAttr | scheme CheckDupID(FDAttr, IDS); // scheme for traverse each FDAttr
CheckDupID(NoAttr, #) → NoAttr;
[data #2] CheckDupID(Attr(#ID, #T, #1), #2) → Attr(#ID, #T, CheckDupID(#1, MatchID(#ID, #2)));

sort FDAttr | scheme AttrExtendDS(Declars, FDAttr) ↓e; // scheme to extend function declarations
  AttrExtendDS(#1, NoAttr) ↓e{:#e} → EnvDS(#1) ↓e{:#e} ;
  AttrExtendDS(#1, Attr(⟦ main ⟧, #T, #2)) ↓e{:#e} → AttrExtendDS(#1, #2) ↓e{:#e} ↓e{⟦ main ⟧ : CheckMain(#T)}; // in here, we explicit the main function and check its function type satisfied main requirement or not
  AttrExtendDS(#1, Attr(#ID, #T, #2)) ↓e{:#e} → AttrExtendDS(#1, #2) ↓e{:#e} ↓e{#ID : #T} ;

sort FDAttr | scheme Trans(FDAttr); // scheme to extend global predefined function declarations
Trans(NoAttr) → Attr(⟦ malloc ⟧, ⟦ ⟨Type ⟦ * char ⟧⟩ ( int ) ⟧, Attr(⟦ puts ⟧, ⟦ int ( ⟨Type ⟦ * char ⟧⟩ ) ⟧, Attr(⟦ puti ⟧, ⟦ int ( int ) ⟧, Attr(⟦ atoi ⟧, ⟦ int ( ⟨Type ⟦ * char ⟧⟩ ) ⟧, Attr(⟦ div ⟧, ⟦ int ( int, int ) ⟧, Attr(⟦ mod ⟧, ⟦ int ( int, int ) ⟧, NoAttr)))))) ;

/***** Define scheme for programs *****/

sort Program | scheme EnvP(Program);
EnvP(⟦⟨Declars#1 ↑fd(#f)⟩⟧↑#syn) → ⟦⟨Declars AttrExtendDS(#1, CheckDupID(AppendAttr(Trans(NoAttr),#f), Nil))↓e{}⟩⟧↑#syn;
/****
In here, we first extend the global predefined functions into declared functions and then check all function name that either it has duplicate name or not.
*****/

/***** Define top level scheme for type analysis *****/

main sort Program | scheme Check(Program) ;
Check(#p) → EnvP(#p);

}
