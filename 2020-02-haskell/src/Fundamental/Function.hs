-- | Fundamental types.
module Fundamental.Function (
  (|>)
, (||>)
, (><)
, (<&>)
, head'
, last'
) where

-- | Right pipe.
infixl 3 |>
(|>) :: a -> (a -> b) -> b
a |> f = f a

-- | Right pipe for tuple.
infixl 3 ||>
(||>) :: (a, b) -> ((a -> c), (b -> d)) -> (c, d)
(a, b) ||> (f1, f2) = ((f1 a), (f2 b))

-- | Fold tuple.
infixl 3 ><
(><) :: (a, b) -> ((a, b) -> c) -> c
(a, b) >< f = f (a, b)

-- | Flipped fmap.
infixl 2 <&>
(<&>) :: Either l r -> (r -> x) -> Either l x
Left l <&> f = Left l
Right r <&> f = Right $ f r

-- | Safe head.
--
-- No exception if list is empty.
head' :: [a] -> [a]
head' [] = []
head' (x:_) = [x]

-- | Safe last.
--
-- No exception if list is empty.
last' :: [a] -> [a]
last' = head' . reverse
