// Pr1Name HACS compiler.
//
module org.crsx.hacs.samples.Pr1Name {

/* ########################################
   #    MiniC Parser Implementation       #
   ########################################
 * Implement the grammar of MiniC.
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
//token MAIN | main ; // This is not using anymore, explained in the doc.

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

/* This is not using anymore, explained in the doc. */
//sort DeclarMain | ⟦ ⟨FUNC⟩ ⟨Type⟩ ⟨MAIN⟩ ( ⟨Param⟩ ) { ⟨Stats⟩ } ⟧ ;


sort Param  | ⟦ ⟨Type⟩ ⟨ID⟩ , ⟨Param⟩ ⟧
            | ⟦ ⟨Type⟩ ⟨ID⟩ ⟧
            | ⟦⟧
    ;

sort Declars | ⟦ ⟨Declar⟩ ⟨Declars⟩ ⟧
             | ⟦ ⟨Declar⟩ ⟧
    ;

/* Define Program */
main sort Program |  ⟦ ⟨Declars⟩ ⟧ ;

}
