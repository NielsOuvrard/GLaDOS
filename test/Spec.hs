import Parser
import ParserModule
import ParserToken
import ParserAST
import Types
import Test.HUnit

parseCharTest :: Test
parseCharTest =
    TestList
    [
        TestCase (assertEqual "parseChar" (Just ('a', "bcd"))           (runParser (parseChar 'a') "abcd")),
        TestCase (assertEqual "parseChar" Nothing                       (runParser (parseChar 'z') "bcd")),
        TestCase (assertEqual "parseChar" Nothing                       (runParser (parseChar 'b') "abcd")),
        TestCase (assertEqual "parseChar" (Just ('a', "aaa"))           (runParser (parseChar 'a') "aaaa"))
    ]

parseStringTest :: Test
parseStringTest =
    TestList
    [
        TestCase (assertEqual "parseString" (Just ("abc", "def"))       (runParser (parseString "abc") "abcdef")),
        TestCase (assertEqual "parseString" Nothing                     (runParser (parseString "abc") "defabc")),
        TestCase (assertEqual "parseString" (Just ("abc", "defg"))      (runParser (parseString "abc") "abcdefg")),
        TestCase (assertEqual "parseString" (Just ("abc", "abc"))       (runParser (parseString "abc") "abcabc")),
        TestCase (assertEqual "parseString" (Just ("abc", ""))          (runParser (parseString "abc") "abc")),
        TestCase (assertEqual "parseString" Nothing                     (runParser (parseString "abc") "ab"))
    ]

parseAnyCharTest :: Test
parseAnyCharTest =
    TestList
    [
        TestCase (assertEqual "parseAnyChar" (Just ('a', "bcd"))        (runParser (parseAnyChar "bca") "abcd")),
        TestCase (assertEqual "parseAnyChar" Nothing                    (runParser (parseAnyChar "xyz") "abcd")),
        TestCase (assertEqual "parseAnyChar" (Just ('c', "def"))        (runParser (parseAnyChar "bca") "cdef"))
    ]

parseOrTest :: Test
parseOrTest =
    TestList
    [
        TestCase (assertEqual "parseOr" (Just ('a', "bcd"))             (runParser (parseOr (parseChar 'a') (parseChar 'b')) "abcd")),
        TestCase (assertEqual "parseOr" (Just ('b', "cda"))             (runParser (parseOr (parseChar 'a') (parseChar 'b')) "bcda")),
        TestCase (assertEqual "parseOr" (Just ('a', "cd"))              (runParser (parseOr (parseChar 'a') (parseChar 'b')) "acd")),
        TestCase (assertEqual "parseOr" Nothing                         (runParser (parseOr (parseChar 'a') (parseChar 'b')) "defg"))
    ]

parseAndTest :: Test
parseAndTest =
    TestList
    [
        TestCase (assertEqual "parseAnd" (Just (('a', 'b'), "cd"))      (runParser (parseAnd (parseChar 'a') (parseChar 'b')) "abcd")),
        TestCase (assertEqual "parseAnd" Nothing                        (runParser (parseAnd (parseChar 'a') (parseChar 'b')) "bcda")),
        TestCase (assertEqual "parseAnd" Nothing                        (runParser (parseAnd (parseChar 'a') (parseChar 'b')) "acd")),
        TestCase (assertEqual "parseAnd" Nothing                        (runParser (parseAnd (parseChar 'a') (parseChar 'b')) "defg"))
    ]

parseAndWithTest :: Test
parseAndWithTest =
    TestList
    [
        TestCase (assertEqual "parseAndWith" (Just ("ab", "cd"))        (runParser (parseAndWith (\x y -> [x,y]) (parseChar 'a') (parseChar 'b')) "abcd")),
        TestCase (assertEqual "parseAndWith" Nothing                    (runParser (parseAndWith (\x y -> [x,y]) (parseChar 'a') (parseChar 'b')) "bcda")),
        TestCase (assertEqual "parseAndWith" Nothing                    (runParser (parseAndWith (\x y -> [x,y]) (parseChar 'a') (parseChar 'b')) "acd")),
        TestCase (assertEqual "parseAndWith" Nothing                    (runParser (parseAndWith (\x y -> [x,y]) (parseChar 'a') (parseChar 'b')) "defg"))
    ]

parseManyTest :: Test
parseManyTest =
    TestList
    [
        TestCase (assertEqual "parseMany" (Just ("aaaa", ""))           (runParser (parseMany (parseChar 'a')) "aaaa")),
        TestCase (assertEqual "parseMany" (Just ("aaa", "b"))           (runParser (parseMany (parseChar 'a')) "aaab")),
        TestCase (assertEqual "parseMany" (Just ("", "baaa"))           (runParser (parseMany (parseChar 'a')) "baaa")),
        TestCase (assertEqual "parseMany" (Just ("", "baab"))           (runParser (parseMany (parseChar 'a')) "baab")),
        TestCase (assertEqual "parseMany" (Just ("    ", "foobar"))     (runParser (parseMany (parseChar ' ')) "    foobar")),
        TestCase (assertEqual "parseMany" (Just ("", "foobar    "))     (runParser (parseMany (parseChar ' ')) "foobar    "))
    ]

parseSomeTest :: Test
parseSomeTest =
    TestList
    [
        TestCase (assertEqual "parseSome" (Just ("aaaa", ""))           (runParser (parseSome (parseChar 'a')) "aaaa")),
        TestCase (assertEqual "parseSome" (Just ("aaa", "b"))           (runParser (parseSome (parseChar 'a')) "aaab")),
        TestCase (assertEqual "parseSome" Nothing                       (runParser (parseSome (parseChar 'a')) "baaa")),
        TestCase (assertEqual "parseSome" Nothing                       (runParser (parseSome (parseChar 'a')) "baab")),
        TestCase (assertEqual "parseSome" (Just ("42", "foobar"))       (runParser (parseSome (parseAnyChar ['0' .. '9'])) "42foobar")),
        TestCase (assertEqual "parseSome" Nothing                       (runParser (parseSome (parseAnyChar ['0' .. '9'])) "foobar42"))
    ]

parseUIntTest :: Test
parseUIntTest =
    TestList
    [
        TestCase (assertEqual "parseUInt" (Just (1234, ""))             (runParser parseUInt "1234")),
        TestCase (assertEqual "parseUInt" (Just (1234, "foobar"))       (runParser parseUInt "1234foobar")),
        TestCase (assertEqual "parseUInt" Nothing                       (runParser parseUInt "foobar")),
        TestCase (assertEqual "parseUInt" (Just (0, ""))                (runParser parseUInt "0")),
        TestCase (assertEqual "parseUInt" (Just (0, ""))                (runParser parseUInt "00")),
        TestCase (assertEqual "parseUInt" (Just (1, ""))                (runParser parseUInt "01")),
        TestCase (assertEqual "parseUInt" (Just (1, ""))                (runParser parseUInt "0001")),
        TestCase (assertEqual "parseUInt" (Just (0, ""))                (runParser parseUInt "0000")),
        TestCase (assertEqual "parseUInt" (Just (42, "foobar"))         (runParser parseUInt "42foobar")),
        TestCase (assertEqual "parseUInt" Nothing                       (runParser parseUInt "-42foobar")),
        TestCase (assertEqual "parseUInt" Nothing                       (runParser parseUInt "+42foobar")),
        TestCase (assertEqual "parseUInt" Nothing                       (runParser parseUInt "foobar42"))
    ]

parseIntTest :: Test
parseIntTest =
    TestList
    [
        TestCase (assertEqual "parseInt" (Just (1234, ""))              (runParser parseInt "1234")),
        TestCase (assertEqual "parseInt" (Just (1234, "foobar"))        (runParser parseInt "1234foobar")),
        TestCase (assertEqual "parseInt" Nothing                        (runParser parseInt "foobar")),
        TestCase (assertEqual "parseInt" (Just (0, ""))                 (runParser parseInt "0")),
        TestCase (assertEqual "parseInt" (Just (0, ""))                 (runParser parseInt "00")),
        TestCase (assertEqual "parseInt" (Just (1, ""))                 (runParser parseInt "01")),
        TestCase (assertEqual "parseInt" (Just (1, ""))                 (runParser parseInt "0001")),
        TestCase (assertEqual "parseInt" (Just (0, ""))                 (runParser parseInt "0000")),
        TestCase (assertEqual "parseInt" (Just (42, "foobar"))          (runParser parseInt "42foobar")),
        TestCase (assertEqual "parseInt" (Just (-42, "foobar"))         (runParser parseInt "-42foobar")),
        TestCase (assertEqual "parseInt" (Just (42, "foobar"))          (runParser parseInt "+42foobar")),
        TestCase (assertEqual "parseInt" Nothing                        (runParser parseInt "foobar42"))
    ]

parsePairTest :: Test
parsePairTest =
    TestList
    [
        TestCase (assertEqual "parsePair" (Just ((1, 2), ""))           (runParser (parsePair parseInt) "(1 2)")),
        TestCase (assertEqual "parsePair" Nothing                       (runParser (parsePair parseInt) "(1 2 3)")),
        TestCase (assertEqual "parsePair" Nothing                       (runParser (parsePair parseInt) "(1)")),
        TestCase (assertEqual "parsePair" Nothing                       (runParser (parsePair parseInt) "(1")),
        TestCase (assertEqual "parsePair" Nothing                       (runParser (parsePair parseInt) "1 2)")),
        TestCase (assertEqual "parsePair" Nothing                       (runParser (parsePair parseInt) "1 2")),
        TestCase (assertEqual "parsePair" Nothing                       (runParser (parsePair parseInt) "1")),
        TestCase (assertEqual "parsePair" Nothing                       (runParser (parsePair parseInt) ""))
    ]

parseOrBothTest :: Test
parseOrBothTest =
    TestList
    [
        TestCase (assertEqual "parseOrBoth" (Just (Left '4', "2foobar"))    (runParser (parseOrBoth (parseChar '4') parseInt) "42foobar")),
        TestCase (assertEqual "parseOrBoth" (Just (Left 42, "foobar"))      (runParser (parseOrBoth parseInt (parseChar '4')) "42foobar")),
        TestCase (assertEqual "parseOrBoth" (Just (Left 42, "foobar"))      (runParser (parseOrBoth parseInt (parseChar 'a')) "42foobar")),
        TestCase (assertEqual "parseOrBoth" (Just (Right '4', "2foobar"))   (runParser (parseOrBoth (parseChar 'a') (parseChar '4')) "42foobar")),
        TestCase (assertEqual "parseOrBoth" Nothing                         (runParser (parseOrBoth (parseChar 'a') (parseChar 'b')) "42foobar"))
    ]

parseListTest :: Test
parseListTest =
    TestList
    [
        TestCase (assertEqual "parseList" (Just ([1, 2], ""))                               (runParser (parseList (parseChar '(') (parseChar ' ') (parseChar ')') (parseChar ' ') parseInt) "(1 2)")),
        TestCase (assertEqual "parseList" (Just ([1, 2, 3], "alut"))                        (runParser (parseList (parseChar '(') (parseChar ' ') (parseChar ')') (parseChar ' ') parseInt) "(1 2 3)alut")),
        TestCase (assertEqual "parseList" (Just ([1, 2, 3], ""))                            (runParser (parseList (parseChar '(') (parseChar ',') (parseChar ')') (parseChar ' ') parseInt) "(1,  2,  3)")),
        TestCase (assertEqual "parseList" Nothing                                           (runParser (parseList (parseChar '(') (parseChar ',') (parseChar ')') (parseChar ' ') parseInt) "alut(1,2,3)")),
        TestCase (assertEqual "parseList" (Just ([1], ""))                                  (runParser (parseList (parseChar '(') (parseChar ' ') (parseChar ')') (parseChar ' ') parseInt) "(1)")),
        TestCase (assertEqual "parseList" Nothing                                           (runParser (parseList (parseChar '(') (parseChar ' ') (parseChar ')') (parseChar ' ') parseInt) "(1")),
        TestCase (assertEqual "parseList" Nothing                                           (runParser (parseList (parseChar '(') (parseChar ' ') (parseChar ')') (parseChar ' ') parseInt) "1 2)")),
        TestCase (assertEqual "parseList" Nothing                                           (runParser (parseList (parseChar '(') (parseChar ' ') (parseChar ')') (parseChar ' ') parseInt) "1 2")),
        TestCase (assertEqual "parseList" Nothing                                           (runParser (parseList (parseChar '(') (parseChar ' ') (parseChar ')') (parseChar ' ') parseInt) "1")),
        TestCase (assertEqual "parseList" Nothing                                           (runParser (parseList (parseChar '(') (parseChar ' ') (parseChar ')') (parseChar ' ') parseInt) "")),
        TestCase (assertEqual "parseList" (Just ([1, 2, 3, 4, 5], ""))                      (runParser (parseList (parseChar '(') (parseChar ' ') (parseChar ')') (parseChar ' ') parseInt) "(1 2 3 4 5)")),
        TestCase (assertEqual "parseList" (Just ([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], ""))  (runParser (parseList (parseChar '(') (parseChar ' ') (parseChar ')') (parseChar ' ') parseInt) "(1 2 3 4 5 6 7 8 9 10 11)"))
    ]

showFileTest :: Test
showFileTest =
    TestList
    [
        TestCase (assertEqual "showFile" "Hello World\n" (show (File ["Hello World"]))),
        TestCase (assertEqual "showFile" "Hello World\n42\n" (show (File ["Hello World", "42"]))),
        TestCase (assertEqual "showFile" "Hello World\n42\n(define my_var 42)\n" (show (File ["Hello World", "42", "(define my_var 42)"])))
    ]

showTokenTest :: Test
showTokenTest =
    TestList
    [
        TestCase (assertEqual "showToken" "OpenPARENTHESIS" (show (OpenParenthesis))),
        TestCase (assertEqual "showToken" "ClosePARENTHESIS" (show (CloseParenthesis))),
        TestCase (assertEqual "showToken" "SPACE" (show (SpaceToken))),
        TestCase (assertEqual "showToken" "IF" (show (IfToken))),
        TestCase (assertEqual "showToken" "ELSEIF" (show (ElseIfToken))),
        TestCase (assertEqual "showToken" "ELSE" (show (ElseToken))),
        TestCase (assertEqual "showToken" "FOR" (show (ForToken))),
        TestCase (assertEqual "showToken" "WHILE" (show (WhileToken))),
        TestCase (assertEqual "showToken" "FUN" (show (FunToken))),
        TestCase (assertEqual "showToken" "FUNTYPE" (show (FunTypeToken))),
        TestCase (assertEqual "showToken" "INT" (show (IntTypeToken))),
        TestCase (assertEqual "showToken" "CHAR" (show (CharTypeToken))),
        TestCase (assertEqual "showToken" "STRING" (show (StringTypeToken))),
        TestCase (assertEqual "showToken" "OpenBRACKET" (show (OpenBracket))),
        TestCase (assertEqual "showToken" "CloseBRACKET" (show (CloseBracket))),
        TestCase (assertEqual "showToken" "OpenBRACES" (show (OpenBraces))),
        TestCase (assertEqual "showToken" "CloseBRACES" (show (CloseBraces))),
        TestCase (assertEqual "showToken" "/*" (show (CommentStart))),
        TestCase (assertEqual "showToken" "*/" (show (CommentEnd))),
        TestCase (assertEqual "showToken" "//" (show (InlineCommentStart))),
        TestCase (assertEqual "showToken" "DEFINE" (show (DefineToken))),
        TestCase (assertEqual "showToken" "42" (show (IntToken 42))),
        TestCase (assertEqual "showToken" "\"Hello World\"" (show (SymbolToken "\"Hello World\""))),
        TestCase (assertEqual "showToken" "\"Hello World\"" (show (StringToken "Hello World"))),
        TestCase (assertEqual "showToken" "'c'" (show (CharToken 'c'))),
        TestCase (assertEqual "showToken" "COMMA" (show (CommaToken))),
        TestCase (assertEqual "showToken" "LineSEPARATOR" (show (LineSeparator))),
        TestCase (assertEqual "showToken" "[1,2,3]" (show (ListToken [IntToken 1, IntToken 2, IntToken 3])))
    ]

equalsTokenTest :: Test
equalsTokenTest =
    TestList
    [
        TestCase (assertEqual "equalsToken" True (OpenParenthesis == OpenParenthesis)),
        TestCase (assertEqual "equalsToken" True (CloseParenthesis == CloseParenthesis)),
        TestCase (assertEqual "equalsToken" True (SpaceToken == SpaceToken)),
        TestCase (assertEqual "equalsToken" True (IfToken == IfToken)),
        TestCase (assertEqual "equalsToken" True (ElseIfToken == ElseIfToken)),
        TestCase (assertEqual "equalsToken" True (ElseToken == ElseToken)),
        TestCase (assertEqual "equalsToken" True (ForToken == ForToken)),
        TestCase (assertEqual "equalsToken" True (WhileToken == WhileToken)),
        TestCase (assertEqual "equalsToken" True (FunToken == FunToken)),
        TestCase (assertEqual "equalsToken" True (FunTypeToken == FunTypeToken)),
        TestCase (assertEqual "equalsToken" True (IntTypeToken == IntTypeToken)),
        TestCase (assertEqual "equalsToken" True (CharTypeToken == CharTypeToken)),
        TestCase (assertEqual "equalsToken" True (StringTypeToken == StringTypeToken)),
        TestCase (assertEqual "equalsToken" True (OpenBracket == OpenBracket)),
        TestCase (assertEqual "equalsToken" True (CloseBracket == CloseBracket)),
        TestCase (assertEqual "equalsToken" True (OpenBraces == OpenBraces)),
        TestCase (assertEqual "equalsToken" True (CloseBraces == CloseBraces)),
        TestCase (assertEqual "equalsToken" True (CommentStart == CommentStart)),
        TestCase (assertEqual "equalsToken" True (CommentEnd == CommentEnd)),
        TestCase (assertEqual "equalsToken" True (InlineCommentStart == InlineCommentStart)),
        TestCase (assertEqual "equalsToken" True (DefineToken == DefineToken)),
        TestCase (assertEqual "equalsToken" True ((IntToken 42) == (IntToken 42))),
        TestCase (assertEqual "equalsToken" True ((SymbolToken "\"Hello World\"") == (SymbolToken "\"Hello World\""))),
        TestCase (assertEqual "equalsToken" True ((StringToken "Hello World") == (StringToken "Hello World"))),
        TestCase (assertEqual "equalsToken" True ((CharToken 'c') == (CharToken 'c'))),
        TestCase (assertEqual "equalsToken" True (CommaToken == CommaToken)),
        TestCase (assertEqual "equalsToken" True (LineSeparator == LineSeparator)),
        TestCase (assertEqual "equalsToken" True ((ListToken [IntToken 1, IntToken 2, IntToken 3]) == (ListToken [IntToken 1, IntToken 2, IntToken 3]))),

        TestCase (assertEqual "equalsToken" False (OpenParenthesis == CloseParenthesis)),
        TestCase (assertEqual "equalsToken" False (CloseParenthesis == SpaceToken)),
        TestCase (assertEqual "equalsToken" False (SpaceToken == IfToken)),
        TestCase (assertEqual "equalsToken" False (IfToken == ElseIfToken)),
        TestCase (assertEqual "equalsToken" False (ElseIfToken == ElseToken)),
        TestCase (assertEqual "equalsToken" False (ElseToken == ForToken)),
        TestCase (assertEqual "equalsToken" False (ForToken == WhileToken)),
        TestCase (assertEqual "equalsToken" False (WhileToken == FunToken)),
        TestCase (assertEqual "equalsToken" False (FunToken == FunTypeToken)),
        TestCase (assertEqual "equalsToken" False (FunTypeToken == IntTypeToken)),
        TestCase (assertEqual "equalsToken" False (IntTypeToken == CharTypeToken)),
        TestCase (assertEqual "equalsToken" False (CharTypeToken == StringTypeToken)),
        TestCase (assertEqual "equalsToken" False (StringTypeToken == OpenBracket)),
        TestCase (assertEqual "equalsToken" False (OpenBracket == CloseBracket)),
        TestCase (assertEqual "equalsToken" False (CloseBracket == OpenBraces)),
        TestCase (assertEqual "equalsToken" False (OpenBraces == CloseBraces)),
        TestCase (assertEqual "equalsToken" False (CloseBraces == CommentStart)),
        TestCase (assertEqual "equalsToken" False (CommentStart == CommentEnd))
    ]

equalsASTTest :: Test
equalsASTTest =
    TestList
    [
        TestCase (assertEqual "equalsAST" True (AST [] == AST [])),
        TestCase (assertEqual "equalsAST" True (AST [DeadLeafAST] == AST [DeadLeafAST])),
        TestCase (assertEqual "equalsAST" True (AST [IntAST 42] == AST [IntAST 42])),
        TestCase (assertEqual "equalsAST" True (AST [SymbolAST "\"Hello World\""] == AST [SymbolAST "\"Hello World\""])),
        TestCase (assertEqual "equalsAST" True (AST [CharAST 'c'] == AST [CharAST 'c'])),
        TestCase (assertEqual "equalsAST" True (AST [AST [IntAST 1, IntAST 2, IntAST 3]] == AST [AST [IntAST 1, IntAST 2, IntAST 3]])),
        TestCase (assertEqual "equalsAST" True (AST [DefineAST "my_var" (AST [IntAST 42])] == AST [DefineAST "my_var" (AST [IntAST 42])])),
        TestCase (assertEqual "equalsAST" True (AST [IfAST (AST [IntAST 1, SymbolAST "<", IntAST 2]) (AST [IntAST 41]) (AST [ElseIfAST (AST [IntAST 1, SymbolAST ">", IntAST 2]) (AST [IntAST 42]) (AST [ElseAST (AST [IntAST 43])])])] == AST [IfAST (AST [IntAST 1, SymbolAST "<", IntAST 2]) (AST [IntAST 41]) (AST [ElseIfAST (AST [IntAST 1, SymbolAST ">", IntAST 2]) (AST [IntAST 42]) (AST [ElseAST (AST [IntAST 43])])])])),
        TestCase (assertEqual "equalsAST" True (AST [ForAST (AST [IntTypeAST,SymbolAST "i",SymbolAST "=",IntAST 0]) (AST [SymbolAST "i",SymbolAST "<",IntAST 10]) (AST [SymbolAST "i++"]) (AST [AST [SymbolAST "a",SymbolAST "=",SymbolAST "a",SymbolAST "+",IntAST 1]])] == AST [ForAST (AST [IntTypeAST,SymbolAST "i",SymbolAST "=",IntAST 0]) (AST [SymbolAST "i",SymbolAST "<",IntAST 10]) (AST [SymbolAST "i++"]) (AST [AST [SymbolAST "a",SymbolAST "=",SymbolAST "a",SymbolAST "+",IntAST 1]])])),
        TestCase (assertEqual "equalsAST" True (AST [WhileAST (AST [SymbolAST "i",SymbolAST "<",IntAST 10]) (AST [AST [SymbolAST "a",SymbolAST "=",SymbolAST "a",SymbolAST "+",IntAST 1]])] == AST [WhileAST (AST [SymbolAST "i",SymbolAST "<",IntAST 10]) (AST [AST [SymbolAST "a",SymbolAST "=",SymbolAST "a",SymbolAST "+",IntAST 1]])])),
        TestCase (assertEqual "equalsAST" True (AST [FunAST "main" (AST [AST [IntTypeAST,SymbolAST "n"],AST [CharTypeAST,SymbolAST "c"]]) (AST [IntTypeAST]) (AST [AST [SymbolAST "return",IntAST 0]])] == AST [FunAST "main" (AST [AST [IntTypeAST,SymbolAST "n"],AST [CharTypeAST,SymbolAST "c"]]) (AST [IntTypeAST]) (AST [AST [SymbolAST "return",IntAST 0]])])),
        TestCase (assertEqual "equalsAST" True (StringAST "Hello World" == StringAST "Hello World")),
        TestCase (assertEqual "equalsAST" True (StringTypeAST == StringTypeAST))
    ]

printASTTest :: Test
printASTTest =
    TestList
    [
        TestCase (assertEqual "printAST" "AST\n" (printAST (AST []))),
        TestCase (assertEqual "printAST" "AST\n|   DefineAST my_var\n|   |   AST\n|   |   |   DeadLeafAST\n" (printAST (AST [DefineAST "my_var" (AST [DeadLeafAST])]))),
        TestCase (assertEqual "printAST" "AST\n|   DefineAST my_var\n|   |   AST\n|   |   |   IntAST 42\n" (printAST (AST [DefineAST "my_var" (AST [IntAST 42])]))),
        TestCase (assertEqual "printAST" "AST\n|   DefineAST my_var\n|   |   AST\n|   |   |   SymbolAST \"Hello World\"\n" (printAST (AST [DefineAST "my_var" (AST [SymbolAST "\"Hello World\""])])))
    ]

parseKeywordTest :: Test
parseKeywordTest =
    TestList
    [
        TestCase (assertEqual "parseKeyword" (Just (IfToken, " (1 2)")) (runParser (parseKeyword "if" IfToken) "if (1 2)")),
        TestCase (assertEqual "parseKeyword" (Just (ElseToken, " if (1 2)")) (runParser (parseKeyword "else" ElseToken) "else if (1 2)")),
        TestCase (assertEqual "parseKeyword" (Just (ElseToken, " (1 2)")) (runParser (parseKeyword "else" ElseToken) "else (1 2)")),
        TestCase (assertEqual "parseKeyword" (Just (ForToken, " (1 2)")) (runParser (parseKeyword "for" ForToken) "for (1 2)")),
        TestCase (assertEqual "parseKeyword" Nothing (runParser (parseKeyword "if" IfToken) "i(1 2)")),
        TestCase (assertEqual "parseKeyword" Nothing (runParser (parseKeyword "else" ElseToken) "elesif(1 2)")),
        TestCase (assertEqual "parseKeyword" Nothing (runParser (parseKeyword "else" ElseToken) "lese"))
    ]

parseIntTokenTest :: Test
parseIntTokenTest =
    TestList
    [
        TestCase (assertEqual "parseIntToken" (Just (IntToken 42, " (1 2)")) (runParser parseIntToken "42 (1 2)")),
        TestCase (assertEqual "parseIntToken" (Just (IntToken 42, "(1 2)")) (runParser parseIntToken "42(1 2)")),
        TestCase (assertEqual "parseIntToken" Nothing (runParser parseIntToken "i42 (1 2)")),
        TestCase (assertEqual "parseIntToken" Nothing (runParser parseIntToken "if (1 2)"))
    ]

parseSymbolTokenTest :: Test
parseSymbolTokenTest =
    TestList
    [
        TestCase (assertEqual "parseSymbolToken" (Just (SymbolToken "H", "ello World (1 2)")) (runParser parseSymbolToken "Hello World (1 2)")),
        TestCase (assertEqual "parseSymbolToken" (Just (SymbolToken "f", "i(1 2)")) (runParser parseSymbolToken "fi(1 2)"))
    ]

parseStringTokenTest :: Test
parseStringTokenTest =
    TestList
    [
        TestCase (assertEqual "parseStringToken" (Just (StringToken "Hello World", " (1 2)")) (runParser parseStringToken "\"Hello World\" (1 2)")),
        TestCase (assertEqual "parseStringToken" (Just (StringToken "Hello World", "(1 2)")) (runParser parseStringToken "\"Hello World\"(1 2)")),
        TestCase (assertEqual "parseStringToken" Nothing (runParser parseStringToken "i\"Hello World\" (1 2)"))
    ]

parseCharTokenTest :: Test
parseCharTokenTest =
    TestList
    [
        TestCase (assertEqual "parseCharToken" (Just (CharToken 'c', " (1 2)")) (runParser parseCharToken "'c' (1 2)")),
        TestCase (assertEqual "parseCharToken" (Just (CharToken 'c', "(1 2)")) (runParser parseCharToken "'c'(1 2)")),
        TestCase (assertEqual "parseCharToken" Nothing (runParser parseCharToken "i'c' (1 2)"))
    ]

parseTokenTest :: Test
parseTokenTest =
    TestList
    [
        TestCase (assertEqual "parseToken" (Just (IntToken 42, " (1 2)")) (runParser parseToken "42 (1 2)")),
        TestCase (assertEqual "parseToken" (Just (SymbolToken "H", "ello World (1 2)")) (runParser parseToken "Hello World (1 2)")),
        TestCase (assertEqual "parseToken" (Just (StringToken "Hello World", " (1 2)")) (runParser parseToken "\"Hello World\" (1 2)")),
        TestCase (assertEqual "parseToken" (Just (CharToken 'c', " (1 2)")) (runParser parseToken "'c' (1 2)")),
        TestCase (assertEqual "parseToken" (Just (OpenParenthesis, " (1 2)")) (runParser parseToken "( (1 2)")),
        TestCase (assertEqual "parseToken" (Just (CloseParenthesis, " (1 2)")) (runParser parseToken ") (1 2)")),
        TestCase (assertEqual "parseToken" (Just (OpenBracket, " (1 2)")) (runParser parseToken "[ (1 2)")),
        TestCase (assertEqual "parseToken" (Just (CloseBracket, " (1 2)")) (runParser parseToken "] (1 2)")),
        TestCase (assertEqual "parseToken" (Just (OpenBraces, " (1 2)")) (runParser parseToken "{ (1 2)")),
        TestCase (assertEqual "parseToken" (Just (CloseBraces, " (1 2)")) (runParser parseToken "} (1 2)")),
        TestCase (assertEqual "parseToken" (Just (CommaToken, " (1 2)")) (runParser parseToken ", (1 2)")),
        TestCase (assertEqual "parseToken" (Just (LineSeparator, " (1 2)")) (runParser parseToken "; (1 2)")),
        TestCase (assertEqual "parseToken" (Just (IfToken, " (1 2)")) (runParser parseToken "if (1 2)")),
        TestCase (assertEqual "parseToken" (Just (ElseToken, " if (1 2)")) (runParser parseToken "else if (1 2)")),
        TestCase (assertEqual "parseToken" (Just (ElseToken, " (1 2)")) (runParser parseToken "else (1 2)")),
        TestCase (assertEqual "parseToken" (Just (ForToken, " (1 2)")) (runParser parseToken "for (1 2)")),
        TestCase (assertEqual "parseToken" (Just (WhileToken, " (1 2)")) (runParser parseToken "while (1 2)")),
        TestCase (assertEqual "parseToken" (Just (FunToken, " (1 2)")) (runParser parseToken "fun (1 2)")),
        TestCase (assertEqual "parseToken" (Just (FunTypeToken, " (1 2)")) (runParser parseToken ": (1 2)")),
        TestCase (assertEqual "parseToken" (Just (IntTypeToken, " (1 2)")) (runParser parseToken "int (1 2)")),
        TestCase (assertEqual "parseToken" (Just (CharTypeToken, " (1 2)")) (runParser parseToken "char (1 2)")),
        TestCase (assertEqual "parseToken" (Just (StringTypeToken, " (1 2)")) (runParser parseToken "string (1 2)")),
        TestCase (assertEqual "parseToken" (Just (CommentStart, " (1 2)")) (runParser parseToken "/* (1 2)")),
        TestCase (assertEqual "parseToken" (Just (CommentEnd, " (1 2)")) (runParser parseToken "*/ (1 2)")),
        TestCase (assertEqual "parseToken" (Just (InlineCommentStart, " (1 2)")) (runParser parseToken "// (1 2)")),
        TestCase (assertEqual "parseToken" (Just (DefineToken, " (1 2)")) (runParser parseToken "#define (1 2)")),
        TestCase (assertEqual "parseToken" (Just (EqualToken, " (1 2)")) (runParser parseToken "== (1 2)")),
        TestCase (assertEqual "parseToken" (Just (NotEqualToken, " (1 2)")) (runParser parseToken "!= (1 2)")),
        TestCase (assertEqual "parseToken" (Just (LessThanToken, " (1 2)")) (runParser parseToken "< (1 2)")),
        TestCase (assertEqual "parseToken" (Just (LessThanEqualToken, " (1 2)")) (runParser parseToken "<= (1 2)")),
        TestCase (assertEqual "parseToken" (Just (GreaterThanToken, " (1 2)")) (runParser parseToken "> (1 2)")),
        TestCase (assertEqual "parseToken" (Just (GreaterThanEqualToken, " (1 2)")) (runParser parseToken ">= (1 2)")),
        TestCase (assertEqual "parseToken" (Just (PlusToken, " (1 2)")) (runParser parseToken "+ (1 2)")),
        TestCase (assertEqual "parseToken" (Just (MinusToken, " (1 2)")) (runParser parseToken "- (1 2)")),
        TestCase (assertEqual "parseToken" (Just (TimesToken, " (1 2)")) (runParser parseToken "* (1 2)")),
        TestCase (assertEqual "parseToken" (Just (DivideToken, " (1 2)")) (runParser parseToken "/ (1 2)")),
        TestCase (assertEqual "parseToken" (Just (ModuloToken, " (1 2)")) (runParser parseToken "% (1 2)")),
        TestCase (assertEqual "parseToken" (Just (AndToken, " (1 2)")) (runParser parseToken "&& (1 2)")),
        TestCase (assertEqual "parseToken" (Just (OrToken, " (1 2)")) (runParser parseToken "|| (1 2)")),
        TestCase (assertEqual "parseToken" (Just (NotToken, " (1 2)")) (runParser parseToken "! (1 2)")),
        TestCase (assertEqual "parseToken" (Just (PlusEqualToken, " (1 2)")) (runParser parseToken "+= (1 2)")),
        TestCase (assertEqual "parseToken" (Just (MinusEqualToken, " (1 2)")) (runParser parseToken "-= (1 2)")),
        TestCase (assertEqual "parseToken" (Just (TimesEqualToken, " (1 2)")) (runParser parseToken "*= (1 2)")),
        TestCase (assertEqual "parseToken" (Just (DivideEqualToken, " (1 2)")) (runParser parseToken "/= (1 2)")),
        TestCase (assertEqual "parseToken" (Just (ModuloEqualToken, " (1 2)")) (runParser parseToken "%= (1 2)")),
        TestCase (assertEqual "parseToken" (Just (IncrementToken, " (1 2)")) (runParser parseToken "++ (1 2)")),
        TestCase (assertEqual "parseToken" (Just (DecrementToken, " (1 2)")) (runParser parseToken "-- (1 2)")),
        TestCase (assertEqual "parseToken" (Just (IntToken 5, " (1 2)")) (runParser parseToken "5 (1 2)")),
        TestCase (assertEqual "parseToken" (Just (FloatToken 5.42, " (1 2)")) (runParser parseToken "5.42 (1 2)")),
        TestCase (assertEqual "parseToken" (Just (SpaceToken, "(1 2)")) (runParser parseToken " (1 2)")),
        TestCase (assertEqual "parseToken" (Just (SpaceToken, "(1 2)")) (runParser parseToken "\t(1 2)"))
    ]

parseLineTest :: Test
parseLineTest =
    TestList
    [
        TestCase (do
            result <- parseLine "42" 0 ""
            assertEqual "parseLine" ([IntToken 42]) (result)
        ),
        TestCase (do
            result <- parseLine "Hello World" 0 ""
            assertEqual "parseLine" ([SymbolToken "H", SymbolToken "e", SymbolToken "l", SymbolToken "l", SymbolToken "o", SpaceToken, SymbolToken "W", SymbolToken "o", SymbolToken "r", SymbolToken "l", SymbolToken "d"]) (result)
        )
    ]

parseFileTest :: Test
parseFileTest =
    TestList
    [
        TestCase (do
            result <- parseFile (File ["42"]) 0 [""]
            assertEqual "parseFile" ([IntToken 42]) (result)
        ),
        TestCase (do
            result <- parseFile (File ["Hello World"]) 0 [""]
            assertEqual "parseFile" ([SymbolToken "Hello", SymbolToken "World"]) (result)
        ),
        TestCase (do
            result <- parseFile (File ["-42", "Hello World"]) 0 [""]
            assertEqual "parseFile" ([IntToken (-42), SymbolToken "Hello", SymbolToken "World"]) (result)
        ),
        TestCase (do
            result <- parseFile (File ["-42.84"]) 0 [""]
            assertEqual "parseFile" ([FloatToken (-42.84)]) (result)
        ),
        TestCase (do
            result <- parseFile (File ["if (1 < 2)"]) 0 [""]
            assertEqual "parseFile" ([IfToken, OpenParenthesis, IntToken 1, LessThanToken, IntToken 2, CloseParenthesis]) (result)
        ),
        TestCase (do
            result <- parseFile (File ["else if (1 > 2)"]) 0 [""]
            assertEqual "parseFile" ([ElseIfToken, OpenParenthesis, IntToken 1, GreaterThanToken, IntToken 2, CloseParenthesis]) (result)
        ),
        TestCase (do
            result <- parseFile (File ["else (1 > 2)"]) 0 [""]
            assertEqual "parseFile" ([ElseToken, OpenParenthesis, IntToken 1, GreaterThanToken, IntToken 2, CloseParenthesis]) (result)
        ),
        TestCase (do
            result <- parseFile (File ["fun my_fun (int n) : int // similar to C"]) 0 [""]
            assertEqual "parseFile" ([FunToken, SymbolToken "my_fun", OpenParenthesis, IntTypeToken, SymbolToken "n", CloseParenthesis, FunTypeToken, IntTypeToken]) (result)
        ),
        TestCase (do
            result <- parseFile (File ["int a = factorial(a, 'a');;; int b = factorial(b, 'b');"]) 0 [""]
            assertEqual "parseFile" ([IntTypeToken, SymbolToken "a", AssignToken, SymbolToken "factorial", OpenParenthesis, SymbolToken "a", CommaToken, CharToken 'a', CloseParenthesis, LineSeparator, IntTypeToken, SymbolToken "b", AssignToken, SymbolToken "factorial", OpenParenthesis, SymbolToken "b", CommaToken, CharToken 'b', CloseParenthesis, LineSeparator]) (result)
        ),
        TestCase (do
            result <- parseFile (File ["int int_my_int = 42"]) 0 [""]
            assertEqual "parseFile" ([IntTypeToken, SymbolToken "int_my_int", AssignToken, IntToken 42]) (result)
        ),
        TestCase (do
            result <- parseFile (File ["char char_my_char = 'c'"]) 0 [""]
            assertEqual "parseFile" ([CharTypeToken, SymbolToken "char_my_char", AssignToken, CharToken 'c']) (result)
        ),
        TestCase (do
            result <- parseFile (File ["string string_my_string = \"Hello World\""]) 0 [""]
            assertEqual "parseFile" ([StringTypeToken, SymbolToken "string_my_string", AssignToken, StringToken "Hello World"]) (result)
        ),
        TestCase (do
            result <- parseFile (File ["int if_my_if = 42"]) 0 [""]
            assertEqual "parseFile" ([IntTypeToken, SymbolToken "if_my_if", AssignToken, IntToken 42]) (result)
        ),
        TestCase (do
            result <- parseFile (File ["int else_my_else = 42"]) 0 [""]
            assertEqual "parseFile" ([IntTypeToken, SymbolToken "else_my_else", AssignToken, IntToken 42]) (result)
        ),
        TestCase (do
            result <- parseFile (File ["int fun_my_fun = 42"]) 0 [""]
            assertEqual "parseFile" ([IntTypeToken, SymbolToken "fun_my_fun", AssignToken, IntToken 42]) (result)
        ),
        TestCase (do
            result <- parseFile (File ["int for_my_for = 42"]) 0 [""]
            assertEqual "parseFile" ([IntTypeToken, SymbolToken "for_my_for", AssignToken, IntToken 42]) (result)
        ),
        TestCase (do
            result <- parseFile (File ["int while_my_while = 42"]) 0 [""]
            assertEqual "parseFile" ([IntTypeToken, SymbolToken "while_my_while", AssignToken, IntToken 42]) (result)
        ),
        TestCase (do
            result <- parseFile (File ["int 42_my_42 = 42"]) 0 [""]
            assertEqual "parseFile" ([IntTypeToken, SymbolToken "42_my_42", AssignToken, IntToken 42]) (result)
        )
    ]

tokenListToSexprTest :: Test
tokenListToSexprTest =
    TestList
    [
        TestCase (do
            tokenList <- parseFile (File ["42"]) 0 [""]
            let result = tokenListToSexpr $ tokenList
            assertEqual "tokenListToSexpr" [IntToken 42] (result)
        ),
        TestCase (do
            tokenList <- parseFile (File ["Hello World"]) 0 [""]
            let result = tokenListToSexpr $ tokenList
            assertEqual "tokenListToSexpr" [SymbolToken "Hello", SymbolToken "World"] (result)
        ),
        TestCase (do
            tokenList <- parseFile (File ["Hello World (42)"]) 0 [""]
            let result = tokenListToSexpr $ tokenList
            assertEqual "tokenListToSexpr" [SymbolToken "Hello", SymbolToken "World", ListToken [IntToken 42]] (result)
        ),
        TestCase (do
            tokenList <- parseFile (File ["fun factorial (int n, char c) /* lol this is a comment to try to break something */: (const my_int) // and this is an inline comment"]) 0 [""]
            let result = tokenListToSexpr $ tokenList
            assertEqual "tokenListToSexpr" [FunToken, SymbolToken "factorial", ListToken [IntTypeToken, SymbolToken "n", CommaToken, CharTypeToken, SymbolToken "c"], ListToken [FunTypeToken, ListToken [SymbolToken "const", SymbolToken "my_int"]]] (result)
        ),
        TestCase (do
            tokenList <- parseFile (File ["fun factorial ((int n), (char c)) /* lol this is a comment to try to break something */: (const my_int) // and this is an inline comment", "{", "int x[2] = {1, 2}" ,"}"]) 0 [""]
            let result = tokenListToSexpr $ tokenList
            assertEqual "tokenListToSexpr" [FunToken, SymbolToken "factorial", ListToken [ListToken [IntTypeToken, SymbolToken "n"], CommaToken, ListToken [CharTypeToken, SymbolToken "c"]], ListToken [FunTypeToken, ListToken [SymbolToken "const", SymbolToken "my_int"]], ListToken [IntTypeToken, SymbolToken "x", ListToken [IntToken 2], AssignToken, ListToken [IntToken 1, CommaToken, IntToken 2]]] (result)
        )
    ]

splitAtValueTest :: Test
splitAtValueTest =
    TestList
    [
        TestCase (assertEqual "splitAtValue" (Just ("Hello", ' ', "World")) (splitAtValue ' ' "Hello World")),
        TestCase (assertEqual "splitAtValue" (Just ("Hello", ' ', "World Me!")) (splitAtValue ' ' "Hello World Me!")),
        TestCase (assertEqual "splitAtValue" (Nothing) (splitAtValue ' ' "Hello_World"))
    ]

splitAtLastValueTest :: Test
splitAtLastValueTest =
    TestList
    [
        TestCase (assertEqual "splitAtLastValue" (Just ("Hello", ' ', "World")) (splitAtLastValue ' ' "Hello World")),
        TestCase (assertEqual "splitAtLastValue" (Just ("Hello World", ' ', "Me!")) (splitAtLastValue ' ' "Hello World Me!")),
        TestCase (assertEqual "splitAtLastValue" (Nothing) (splitAtLastValue ' ' "Hello_World"))
    ]

testParsingFunction :: Test
testParsingFunction =
    TestList
        [
            TestLabel "showFile" showFileTest,
            TestLabel "showToken" showTokenTest,
            TestLabel "equalsToken" equalsTokenTest,
            TestLabel "equalsAST" equalsASTTest,
            TestLabel "printAST" printASTTest,

            TestLabel "parseKeyword" parseKeywordTest,
            TestLabel "parseIntToken" parseIntTokenTest,
            TestLabel "parseSymbolToken" parseSymbolTokenTest,
            TestLabel "parseStringToken" parseStringTokenTest,
            TestLabel "parseCharToken" parseCharTokenTest,
            TestLabel "parseToken" parseTokenTest,
            TestLabel "parseLine" parseLineTest,
            TestLabel "parseFile" parseFileTest,

            TestLabel "tokenListToSexpr" tokenListToSexprTest,

            TestLabel "splitAtValue" splitAtValueTest,
            TestLabel "splitAtLastValue" splitAtLastValueTest,

            TestLabel "parseChar" parseCharTest,
            TestLabel "parseString" parseStringTest,
            TestLabel "parseAnyChar" parseAnyCharTest,
            TestLabel "parseOr" parseOrTest,
            TestLabel "parseAnd" parseAndTest,
            TestLabel "parseAndWith" parseAndWithTest,
            TestLabel "parseMany" parseManyTest,
            TestLabel "parseSome" parseSomeTest,
            TestLabel "parseUInt" parseUIntTest,
            TestLabel "parseInt" parseIntTest,
            TestLabel "parsePair" parsePairTest,
            TestLabel "parseOrBoth" parseOrBothTest,
            TestLabel "parseList" parseListTest
        ]

main :: IO ()
main = do
    putStrLn "Running tests..."
    putStrLn "Running Parsing tests..."
    _ <- runTestTT testParsingFunction
    putStrLn "Running other tests..."
    -- do other tests
    putStrLn "Done"
