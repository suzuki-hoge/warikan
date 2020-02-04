module Fundamental.Function (
  (|>)
, (||>)
, (><)
, (<&>)
, head'
, last'
) where

infixl 3 |>
(|>) :: a -> (a -> b) -> b
a |> f = f a

infixl 3 ||>
(||>) :: (a, b) -> ((a -> c), (b -> d)) -> (c, d)
(a, b) ||> (f1, f2) = ((f1 a), (f2 b))

infixl 3 ><
(><) :: (a, b) -> ((a, b) -> c) -> c
(a, b) >< f = f (a, b)

infixl 2 <&>
(<&>) :: Either l r -> (r -> x) -> Either l x
Left l <&> f = Left l
Right r <&> f = Right $ f r

head' :: [a] -> [a]
head' [] = []
head' (x:_) = [x]

last' :: [a] -> [a]
last' = head' . reverse
