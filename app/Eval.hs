module Eval (evalAST) where

import Types
import Debug.Trace


-- * -------------------------------- COMPARE -------------------------------- * --

compareEqualAST :: AST -> AST -> AST
compareEqualAST x y =
    case (x, y) of
        (IntAST x', IntAST y') -> if x' == y' then IntAST 1 else IntAST 0
        (SymbolAST x', SymbolAST y') -> if x' == y' then IntAST 1 else IntAST 0
        (SymbolAST x', IntAST y') -> if x' == show y' then IntAST 1 else IntAST 0
        (IntAST x', SymbolAST y') -> if show x' == y' then IntAST 1 else IntAST 0
        _ -> DeadLeafAST

compareGreaterAST :: AST -> AST -> AST
compareGreaterAST x y =
    case (x, y) of
        (IntAST x', IntAST y') -> if x' > y' then IntAST 1 else IntAST 0
        (SymbolAST x', SymbolAST y') -> if x' > y' then IntAST 1 else IntAST 0
        (SymbolAST x', IntAST y') -> if x' > show y' then IntAST 1 else IntAST 0
        (IntAST x', SymbolAST y') -> if show x' > y' then IntAST 1 else IntAST 0
        _ -> DeadLeafAST

compareLessAST :: AST -> AST -> AST
compareLessAST x y =
    case (x, y) of
        (IntAST x', IntAST y') -> if x' < y' then IntAST 1 else IntAST 0
        (SymbolAST x', SymbolAST y') -> if x' < y' then IntAST 1 else IntAST 0
        (SymbolAST x', IntAST y') -> if x' < show y' then IntAST 1 else IntAST 0
        (IntAST x', SymbolAST y') -> if show x' < y' then IntAST 1 else IntAST 0
        _ -> DeadLeafAST

compareLessEqualAST :: AST -> AST -> AST
compareLessEqualAST x y =
    case (x, y) of
        (IntAST x', IntAST y') -> if x' <= y' then IntAST 1 else IntAST 0
        (SymbolAST x', SymbolAST y') -> if x' <= y' then IntAST 1 else IntAST 0
        (SymbolAST x', IntAST y') -> if x' <= show y' then IntAST 1 else IntAST 0
        (IntAST x', SymbolAST y') -> if show x' <= y' then IntAST 1 else IntAST 0
        _ -> DeadLeafAST

compareGreaterEqualAST :: AST -> AST -> AST
compareGreaterEqualAST x y =
    case (x, y) of
        (IntAST x', IntAST y') -> if x' >= y' then IntAST 1 else IntAST 0
        (SymbolAST x', SymbolAST y') -> if x' >= y' then IntAST 1 else IntAST 0
        (SymbolAST x', IntAST y') -> if x' >= show y' then IntAST 1 else IntAST 0
        (IntAST x', SymbolAST y') -> if show x' >= y' then IntAST 1 else IntAST 0
        _ -> DeadLeafAST

compareNotEqualAST :: AST -> AST -> AST
compareNotEqualAST x y =
    case (x, y) of
        (IntAST x', IntAST y') -> if x' /= y' then IntAST 1 else IntAST 0
        (SymbolAST x', SymbolAST y') -> if x' /= y' then IntAST 1 else IntAST 0
        (SymbolAST x', IntAST y') -> if x' /= show y' then IntAST 1 else IntAST 0
        (IntAST x', SymbolAST y') -> if show x' /= y' then IntAST 1 else IntAST 0
        _ -> DeadLeafAST


-- * --------------------------------- MATH ---------------------------------- * --

addAST :: AST -> AST -> AST
addAST x y =
    case (x, y) of
        (IntAST x', IntAST y') -> IntAST (x' + y')
        (SymbolAST x', SymbolAST y') -> SymbolAST (x' ++ y')
        (SymbolAST x', IntAST y') -> SymbolAST (x' ++ show y')
        (IntAST x', SymbolAST y') -> SymbolAST (show x' ++ y')
        _ -> DeadLeafAST

subAST :: AST -> AST -> AST
subAST x y =
    case (x, y) of
        (IntAST x', IntAST y') -> IntAST (x' - y')
        (SymbolAST x', SymbolAST y') -> SymbolAST (x' ++ y')
        (SymbolAST x', IntAST y') -> SymbolAST (x' ++ show y')
        (IntAST x', SymbolAST y') -> SymbolAST (show x' ++ y')
        _ -> DeadLeafAST

mulAST :: AST -> AST -> AST
mulAST x y =
    case (x, y) of
        (IntAST x', IntAST y') -> IntAST (x' * y')
        (SymbolAST x', SymbolAST y') -> SymbolAST (x' ++ y')
        (SymbolAST x', IntAST y') -> SymbolAST (x' ++ show y')
        (IntAST x', SymbolAST y') -> SymbolAST (show x' ++ y')
        _ -> DeadLeafAST

divAST :: AST -> AST -> AST
divAST x y =
    case (x, y) of
        (IntAST x', IntAST y') -> IntAST (x' `div` y')
        (SymbolAST x', SymbolAST y') -> SymbolAST (x' ++ y')
        (SymbolAST x', IntAST y') -> SymbolAST (x' ++ show y')
        (IntAST x', SymbolAST y') -> SymbolAST (show x' ++ y')
        _ -> DeadLeafAST

modAST :: AST -> AST -> AST
modAST x y =
    case (x, y) of
        (IntAST x', IntAST y') -> IntAST (x' `mod` y')
        (SymbolAST x', SymbolAST y') -> SymbolAST (x' ++ y')
        (SymbolAST x', IntAST y') -> SymbolAST (x' ++ show y')
        (IntAST x', SymbolAST y') -> SymbolAST (show x' ++ y')
        _ -> DeadLeafAST


-- * --------------------------------- EVAL ---------------------------------- * --

evalAST :: AST -> AST
evalAST (AST []) = DeadLeafAST
evalAST (AST (SymbolAST "=" : x : y : _)) = traceLittleMsg "USAGE : '=' give" x $ compareEqualAST x y
evalAST (AST (SymbolAST ">" : x : y : _)) = traceLittleMsg "USAGE : '>' give" x $ compareGreaterAST x y
evalAST (AST (SymbolAST "<" : x : y : _)) = traceLittleMsg "USAGE : '<' give" x $ compareLessAST x y
evalAST (AST (SymbolAST "<=" : x : y : _)) = traceLittleMsg "USAGE : '<=' give" x $ compareLessEqualAST x y
evalAST (AST (SymbolAST ">=" : x : y : _)) = traceLittleMsg "USAGE : '>=' give" x $ compareGreaterEqualAST x y
evalAST (AST (SymbolAST "!=" : x : y : _)) = traceLittleMsg "USAGE : '!=' give" x $ compareNotEqualAST x y
evalAST (AST (SymbolAST "+" : x : y : _)) = traceLittleMsg "USAGE : '+' give" x $ addAST x y
evalAST (AST (SymbolAST "-" : x : y : _)) = traceLittleMsg "USAGE : '-' give" x $ subAST x y
evalAST (AST (SymbolAST "*" : x : y : _)) = traceLittleMsg "USAGE : '*' give" x $ mulAST x y
evalAST (AST (SymbolAST "/" : x : y : _)) = traceLittleMsg "USAGE : '/' give" x $ divAST x y
evalAST (AST (SymbolAST "%" : x : y : _)) = traceLittleMsg "USAGE : '%' give" x $ modAST x y
evalAST (AST (x:xs)) = traceMsg "AST:" x xs $ evalAST x
evalAST (IfAST cond expr1 expr2) = traceMsg "IfAST: Condition =" cond [expr1, expr2] $
    case evalAST cond of
        IntAST 0 -> traceMsg "IfAST: Condition is 0, evaluating expr2" expr2 [] $ evalAST expr2
        IntAST _ -> traceMsg "IfAST: Condition is non-zero, evaluating expr1" expr1 [] $ evalAST expr1
        _ -> traceMsg "IfAST: Condition is not an integer, returning DeadLeafAST" DeadLeafAST [] DeadLeafAST
evalAST (DefineAST name expr) = traceMsg ("Defining: " ++ name) expr [] $ evalAST expr
evalAST (LambdaAST args body) = traceMsg "Lambda:" args [body] $ evalAST body
evalAST (IntAST x) = IntAST x
evalAST (SymbolAST x) = SymbolAST x
evalAST _ = DeadLeafAST

traceLittleMsg :: String -> AST -> AST -> AST
traceLittleMsg msg arg result =
    trace (msg ++ " " ++ printAST arg ++ " => " ++ printAST result) result


traceMsg :: String -> AST -> [AST] -> AST -> AST
traceMsg msg arg _ result =
    trace (msg ++ " " ++ printAST arg ++ " => " ++ printAST result) result