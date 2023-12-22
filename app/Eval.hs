module Eval (evalAST) where

import Types
import Debug.Trace
import Data.List (find)
import Data.List (isPrefixOf)
import Data.List.Split (splitOn)

-- * -------------------------------- COMPARE -------------------------------- * --

compareEqualAST :: Environment -> AST -> AST -> (Environment, AST)
compareEqualAST env x y =
    let (env1, evaluatedX) = evalAST env x
        (env2, evaluatedY) = evalAST env1 y
    in case (evaluatedX, evaluatedY) of
        (IntAST x', IntAST y') -> (env2, if x' == y' then IntAST 1 else IntAST 0)
        (SymbolAST x', SymbolAST y') -> (env2, if x' == y' then IntAST 1 else IntAST 0)
        (SymbolAST x', IntAST y') -> (env2, if x' == show y' then IntAST 1 else IntAST 0)
        (IntAST x', SymbolAST y') -> (env2, if show x' == y' then IntAST 1 else IntAST 0)
        _ -> (env2, DeadLeafAST)


-- ? it is useful to have compareGreaterAST and evalGreaterAST ?

compareGreaterAST :: Environment -> AST -> AST -> (Environment, AST)
compareGreaterAST = evalGreaterAST

evalGreaterAST :: Environment -> AST -> AST -> (Environment, AST)
evalGreaterAST env x y =
    let (env1, evaluatedX) = evalAST env x
        (env2, evaluatedY) = evalAST env1 y
    in case (evaluatedX, evaluatedY) of
            (IntAST x', IntAST y') -> (env2, if x' > y' then IntAST 1 else IntAST 0)
            (SymbolAST x', SymbolAST y') -> (env2, if x' > y' then IntAST 1 else IntAST 0)
            (SymbolAST x', IntAST y') -> (env2, if x' > show y' then IntAST 1 else IntAST 0)
            (IntAST x', SymbolAST y') -> (env2, if show x' > y' then IntAST 1 else IntAST 0)
            _ -> (env2, DeadLeafAST)


compareLessAST :: Environment -> AST -> AST -> (Environment, AST)
compareLessAST = evalLessAST

evalLessAST :: Environment -> AST -> AST -> (Environment, AST)
evalLessAST env x y =
    let (env1, evaluatedX) = evalAST env x
        (env2, evaluatedY) = evalAST env1 y
    in case (evaluatedX, evaluatedY) of
        (IntAST x', IntAST y') -> (env2, if x' < y' then IntAST 1 else IntAST 0)
        (SymbolAST x', SymbolAST y') -> (env2, if x' < y' then IntAST 1 else IntAST 0)
        (SymbolAST x', IntAST y') -> (env2, if x' < show y' then IntAST 1 else IntAST 0)
        (IntAST x', SymbolAST y') -> (env2, if show x' < y' then IntAST 1 else IntAST 0)
        _ -> (env2, DeadLeafAST)


compareLessEqualAST :: Environment -> AST -> AST -> (Environment, AST)
compareLessEqualAST = evalLessEqualAST

evalLessEqualAST :: Environment -> AST -> AST -> (Environment, AST)
evalLessEqualAST env x y =
    let (env1, evaluatedX) = evalAST env x
        (env2, evaluatedY) = evalAST env1 y
    in case (evaluatedX, evaluatedY) of
        (IntAST x', IntAST y') -> (env2, if x' <= y' then IntAST 1 else IntAST 0)
        (SymbolAST x', SymbolAST y') -> (env2, if x' <= y' then IntAST 1 else IntAST 0)
        (SymbolAST x', IntAST y') -> (env2, if x' <= show y' then IntAST 1 else IntAST 0)
        (IntAST x', SymbolAST y') -> (env2, if show x' <= y' then IntAST 1 else IntAST 0)
        _ -> (env2, DeadLeafAST)


compareGreaterEqualAST :: Environment -> AST -> AST -> (Environment, AST)
compareGreaterEqualAST = evalGreaterEqualAST

evalGreaterEqualAST :: Environment -> AST -> AST -> (Environment, AST)
evalGreaterEqualAST env x y =
    let (env1, evaluatedX) = evalAST env x
        (env2, evaluatedY) = evalAST env1 y
    in case (evaluatedX, evaluatedY) of
        (IntAST x', IntAST y') -> (env2, if x' >= y' then IntAST 1 else IntAST 0)
        (SymbolAST x', SymbolAST y') -> (env2, if x' >= y' then IntAST 1 else IntAST 0)
        (SymbolAST x', IntAST y') -> (env2, if x' >= show y' then IntAST 1 else IntAST 0)
        (IntAST x', SymbolAST y') -> (env2, if show x' >= y' then IntAST 1 else IntAST 0)
        _ -> (env2, DeadLeafAST)

compareNotEqualAST :: Environment -> AST -> AST -> (Environment, AST)
compareNotEqualAST = evalNotEqualAST

evalNotEqualAST :: Environment -> AST -> AST -> (Environment, AST)
evalNotEqualAST env x y =
    let (env1, evaluatedX) = evalAST env x
        (env2, evaluatedY) = evalAST env1 y
    in case (evaluatedX, evaluatedY) of
        (IntAST x', IntAST y') -> (env2, if x' /= y' then IntAST 1 else IntAST 0)
        (SymbolAST x', SymbolAST y') -> (env2, if x' /= y' then IntAST 1 else IntAST 0)
        (SymbolAST x', IntAST y') -> (env2, if x' /= show y' then IntAST 1 else IntAST 0)
        (IntAST x', SymbolAST y') -> (env2, if show x' /= y' then IntAST 1 else IntAST 0)
        _ -> (env2, DeadLeafAST)

-- * --------------------------------- MATH ---------------------------------- * --

addAST :: Environment -> AST -> AST -> (Environment, AST)
addAST env x y =
    let (env1, evaluatedX) = evalAST env x
        (env2, evaluatedY) = evalAST env1 y
    in case (evaluatedX, evaluatedY) of
        (IntAST x', IntAST y') -> (env2, IntAST (x' + y'))
        (SymbolAST x', SymbolAST y') -> (env2, IntAST (read x' + read y'))
        (SymbolAST x', IntAST y') -> (env2, IntAST (read x' + y'))
        (IntAST x', SymbolAST y') -> (env2, IntAST (x' + read y'))
        _ -> (env2, DeadLeafAST)


subAST :: Environment -> AST -> AST -> (Environment, AST)
subAST = evalSubAST

evalSubAST :: Environment -> AST -> AST -> (Environment, AST)
evalSubAST env x y =
    let (env1, evaluatedX) = evalAST env x
        (env2, evaluatedY) = evalAST env1 y
    in case (evaluatedX, evaluatedY) of
        (IntAST x', IntAST y') -> (env2, IntAST (x' - y'))
        (SymbolAST x', SymbolAST y') -> (env2, IntAST (read x' - read y'))
        (SymbolAST x', IntAST y') -> (env2, IntAST (read x' - y'))
        (IntAST x', SymbolAST y') -> (env2, IntAST (x' - read y'))
        _ -> (env2, DeadLeafAST)


mulAST :: Environment -> AST -> AST -> (Environment, AST)
mulAST = evalMulAST

evalMulAST :: Environment -> AST -> AST -> (Environment, AST)
evalMulAST env x y =
    let (env1, evaluatedX) = evalAST env x
        (env2, evaluatedY) = evalAST env1 y
    in case (evaluatedX, evaluatedY) of
        (IntAST x', IntAST y') -> (env2, IntAST (x' * y'))
        (SymbolAST x', SymbolAST y') -> (env2, IntAST (read x' * read y'))
        (SymbolAST x', IntAST y') -> (env2, IntAST (read x' * y'))
        (IntAST x', SymbolAST y') -> (env2, IntAST (x' * read y'))
        _ -> (env2, DeadLeafAST)


divAST :: Environment -> AST -> AST -> (Environment, AST)
divAST = evalDivAST

evalDivAST :: Environment -> AST -> AST -> (Environment, AST)
evalDivAST env x y =
    let (env1, evaluatedX) = evalAST env x
        (env2, evaluatedY) = evalAST env1 y
    in case (evaluatedX, evaluatedY) of
        (IntAST x', IntAST y') -> (env2, if y' /= 0 then IntAST (x' `div` y') else DeadLeafAST)
        (SymbolAST x', SymbolAST y') -> (env2, IntAST (read x' `div` read y'))
        (SymbolAST x', IntAST y') -> (env2, IntAST (read x' `div` y'))
        (IntAST x', SymbolAST y') -> (env2, IntAST (x' `div` read y'))
        _ -> (env2, DeadLeafAST)


modAST :: Environment -> AST -> AST -> (Environment, AST)
modAST = evalModAST

evalModAST :: Environment -> AST -> AST -> (Environment, AST)
evalModAST env x y =
    let (env1, evaluatedX) = evalAST env x
        (env2, evaluatedY) = evalAST env1 y
    in case (evaluatedX, evaluatedY) of
        (IntAST x', IntAST y') -> (env2, if y' /= 0 then IntAST (x' `mod` y') else DeadLeafAST)
        (SymbolAST x', SymbolAST y') -> (env2, IntAST (read x' `mod` read y'))
        (SymbolAST x', IntAST y') -> (env2, IntAST (read x' `mod` y'))
        (IntAST x', SymbolAST y') -> (env2, IntAST (x' `mod` read y'))
        _ -> (env2, DeadLeafAST)


-- * --------------------------------- EVAL ---------------------------------- * --

getParamsASTFromLambda :: AST -> [String]
getParamsASTFromLambda (LambdaAST (AST params) _) = map extractParam params
getParamsASTFromLambda _ = []

extractParam :: AST -> String
extractParam (SymbolAST paramName) = paramName
extractParam _ = error "Invalid parameter format in LambdaAST"


addToEnv :: Environment -> String -> AST -> Environment
addToEnv env name (AST (LambdaAST params body : _)) = (name, LambdaAST params body) : env
addToEnv env name (IntAST x) = (name, IntAST x) : env
addToEnv env name (SymbolAST x) = (name, SymbolAST x) : env
addToEnv env name (LambdaAST params body) = (name, LambdaAST params body) : env
addToEnv env name (AST x) =
    let (_, evaluatedAST) = evalAST env (AST x)
    in (name, evaluatedAST) : env
addToEnv env name what = (name, DeadLeafAST) : env

-- * This code prevent from adding the same value to env
-- addToEnv :: Environment -> String -> AST -> Environment
-- addToEnv env name (AST (LambdaAST params body : _)) = updateEnv env name (LambdaAST params body)
-- addToEnv env name (IntAST x) = updateEnv env name (IntAST x)
-- addToEnv env name (SymbolAST x) = updateEnv env name (SymbolAST x)
-- addToEnv env name (LambdaAST params body) = updateEnv env name (LambdaAST params body)
-- addToEnv env name (AST (x:_)) = updateEnv env name x
-- addToEnv env name what = updateEnv env name (DeadLeafAST)

-- updateEnv :: Environment -> String -> AST -> Environment
-- updateEnv [] name value = [(name, value)]
-- updateEnv ((n, v) : rest) name value
--     | n == name = (name, value) : rest
--     | otherwise = (n, v) : updateEnv rest name value

addFunctionCalledToAST :: Environment -> String -> AST -> AST
addFunctionCalledToAST env name (AST (x:xs)) =
    let (env1, result) = evalAST env x
    in AST (SymbolAST name : result : xs)

extractParams :: String -> [String]
extractParams input = case splitOn "," $ init $ tail input of
  (_:params) -> params
  _          -> []

evalAST :: Environment -> AST -> (Environment, AST)
evalAST env expr
    | length env > 10 = (env, DeadLeafAST)
evalAST env expr = case expr of
    AST [] -> trace "Empty AST" (env, DeadLeafAST)

    AST (SymbolAST "=" : x : y : _) -> let (_, resultAST) = compareEqualAST env x y in (env, resultAST)
    AST (SymbolAST ">" : x : y : _) -> let (_, resultAST) = compareGreaterAST env x y in (env, resultAST)
    AST (SymbolAST "<" : x : y : _) -> let (_, resultAST) = compareLessAST env x y in (env, resultAST)
    AST (SymbolAST "<=" : x : y : _) -> let (_, resultAST) = compareLessEqualAST env x y in (env, resultAST)
    AST (SymbolAST ">=" : x : y : _) -> let (_, resultAST) = compareGreaterEqualAST env x y in (env, resultAST)
    AST (SymbolAST "!=" : x : y : _) -> let (_, resultAST) = compareNotEqualAST env x y in (env, resultAST)
    AST (SymbolAST "+" : x : y : _) -> let (_, resultAST) = addAST env x y in (env, resultAST)
    AST (SymbolAST "-" : x : y : _) -> let (_, resultAST) = subAST env x y in (env, resultAST)
    AST (SymbolAST "*" : x : y : _) -> let (_, resultAST) = mulAST env x y in (env, resultAST)
    AST (SymbolAST "/" : x : y : _) -> let (_, resultAST) = divAST env x y in (env, resultAST)
    AST (SymbolAST "%" : x : y : _) -> let (_, resultAST) = modAST env x y in (env, resultAST)

    IfAST cond expr1 expr2 ->
        let (env1, resultCond) = evalAST env cond
        in case resultCond of
                IntAST 0 -> evalAST env1 expr2
                IntAST _ -> evalAST env1 expr1
                _ -> (env1, DeadLeafAST)

    DefineAST name expr1 ->
        let newEnv = addToEnv env name expr1
        in (newEnv, expr1)



    LambdaAST paramsAST body ->
        let params = extractArgs paramsAST
        in evalAST env (LambdaClosure params body env)



    AST (x:xs) ->
        case x of
            SymbolAST funcName ->
                case find (\(name, para) -> name == funcName) env of
                    Just (funct, val) ->
                        let paramBindings = zip (getParamsASTFromLambda val) xs
                            newEnv = foldl (\acc (param, value) -> addToEnv acc param value) env paramBindings
                        in evalAST newEnv val
                    Nothing -> (env, DeadLeafAST)

            AST name -> evalASTSequence env (x:xs)
            _ -> evalASTSequence env (x:xs)

    LambdaClosure params body closureEnv ->
            let (newEnv, result) = evalASTSequence closureEnv [body]
            in (env, result)



    IntAST x -> (env, IntAST x)
    SymbolAST x ->
        case find (\(name, _) -> name == x) env of
            Just (_, val) -> (env, val)
            Nothing -> (env, DeadLeafAST)
    _ -> (env, DeadLeafAST)

evalASTSequence :: Environment -> [AST] -> (Environment, AST)
evalASTSequence env [] = (env, DeadLeafAST)
evalASTSequence env [x] = evalAST env x
evalASTSequence env (x:xs) =
    let (newEnv, _) = evalAST env x
    in evalASTSequence newEnv xs

extractArgs :: AST -> [String]
extractArgs (AST []) = []
extractArgs (AST (SymbolAST x : xs)) = x : extractArgs (AST xs)
extractArgs _ = []
