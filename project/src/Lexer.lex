import java_cup.runtime.*;

%%

%class Lexer
%unicode
%cup
%line
%column

%{
    private StringBuffer characters = new StringBuffer();

    private Symbol symbol(int type) {
        return new Symbol(type, yyline, yycolumn);
    }

    private Symbol symbol(int type, Object value) {
        return new Symbol(type, yyline, yycolumn, value);
    }
%}

LineTerminator = \r | \n | \r\n
InputCharacter = [^\r\n]
WhiteSpace = {LineTerminator} | " " | \t | \f

Letter = [a-zA-Z]
Digit = [0-9]
IdComponent = {Letter} | {Digit} | "_"
Identifier = {Letter}{IdComponent}*
Integer = (0|[1-9]{Digit}*)
Float = {Integer} "." {Integer}
Rational = ({Integer}+"_")?{Integer}"/"{Integer}
Characters = '[\x00-\x7F]'

Security = "H" | "L"
Boolean = "T" | "F"

Comment = {MultiComment} | {Comment}
MultiComment = "/#" [^#]* ~"#/"
Comment = "#" {InputCharacter}* {LineTerminator}?

%state STRING

%%

<YYINITIAL>{

      //Types
      "int"                   { return symbol(sym.INT);       }
      "float"                 { return symbol(sym.FLOAT);     }
      "rational"              { return symbol(sym.RAT);       }
      "char"                  { return symbol(sym.CHAR);      }
      "seq"                   { return symbol(sym.SEQ);       }
      "top"                   { return symbol(sym.TOP);       }
      "boolean"               { return symbol(sym.BOOL);      }

      //Security labels

      {Security}              { return symbol(sym.SEC);       }

      //Boolean
      {Boolean}               { return symbol(sym.BOOL);      }

      //Keywords
      "loop"                  { return symbol(sym.LOOP);      }
      "pool"                  { return symbol(sym.POOL);      }
      "if"                    { return symbol(sym.IF);        }
      "then"                  { return symbol(sym.THEN);      }
      "else"                  { return symbol(sym.ELSE);      }
      "break"                 { return symbol(sym.BREAK);     }
      "fi"                    { return symbol(sym.FI);        }
      "read"                  { return symbol(sym.READ);      }
      "tdef"                  { return symbol(sym.TDEF);      }
      "fdef"                  { return symbol(sym.FDEF);      }
      "print"                 { return symbol(sym.PRINT);     }
      "return"                { return symbol(sym.RETURN);    }
      "main"                  { return symbol(sym.MAIN);      }

      //Operators
      "+"                     { return symbol(sym.PLUS);      }
      "-"                     { return symbol(sym.MINUS);     }
      "*"                     { return symbol(sym.MULT);      }
      "/"                     { return symbol(sym.DIV);       }
      "^"                     { return symbol(sym.POWER);     }
      ":"                     { return symbol(sym.COLON);     }
      "."                     { return symbol(sym.DOT);       }
      ">"                     { return symbol(sym.GREATER);   }
      "<"                     { return symbol(sym.LESS);      }
      "<="                    { return symbol(sym.LESSEQ);    }
      ">="                    { return symbol(sym.GREATEREQ); }
      "="                     { return symbol(sym.EQUAL);     }
      ":="                    { return symbol(sym.ASSIGN);    }
      "!="                    { return symbol(sym.NOTEQ);     }
      "!"                     { return symbol(sym.NOT);       }
      "&&"                    { return symbol(sym.AND);       }
      "||"                    { return symbol(sym.OR);        }
      "in"                    { return symbol(sym.IN);        }
      "::"                    { return symbol(sym.CONCAT);    }

      //Group
      "("                     { return symbol(sym.LPAREN);    }
      ")"                     { return symbol(sym.RPAREN);    }
      "["                     { return symbol(sym.LBRACKET);  }
      "]"                     { return symbol(sym.RBRACKET);  }
      "{"                     { return symbol(sym.LBRACE);    }
      "}"                     { return symbol(sym.RBRACE);    }

      //Separators
      ";"                     { return symbol(sym.SEMICOLON); }
      ","                     { return symbol(sym.COMMA);     }

      //Literals
      "null"			            { return symbol(sym.NULL);	    }
      {Identifier}	          { return symbol(sym.ID, yytext()); }
      {Float}		            	{ return symbol(sym.FLOAT, new Double(yytext())); }
      {Rational}		          { return symbol(sym.RAT, yytext());	}
      {Integer}		            { return symbol(sym.INT, new Integer(yytext()));	}
      {Characters}		          { return symbol(sym.CHAR, new Character(yytext().charAt(1))); }
      \"				              { yybegin(YYINITIAL); return symbol(
                                        sym.STRING, characters.toString()); }

      //Ignore
      {Comment}               { /* ignore this */ }
      {WhiteSpace}            { /* ignore this */ }

}

<STRING>{

      \\0                     { characters.append('\0'); }
      \\                      { characters.append('\\'); }
      \\t                     { characters.append('\t'); }
      \\n                     { characters.append('\n'); }
      \\r                     { characters.append('\r'); }
      \\b                     { characters.append('\b'); }
      \\f                     { characters.append('\f'); }

}

//Error
[^]                 {
                      System.out.println("file: " + (yyline + 1) +
                      ":0: Error: Invalid Input '" + yytext()+"'");
                        }
