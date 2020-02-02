module Pipe (
  (|>)
, (||>)
, (><)
) where

infixl 2 |>
(|>) :: a -> (a -> b) -> b
a |> f = f a

(||>) :: (a, b) -> ((a -> c), (b -> d)) -> (c, d)
(a, b) ||> (f1, f2) = ((f1 a), (f2 b))

(><) :: (a, b) -> ((a, b) -> c) -> c
(a, b) >< f = f (a, b)
