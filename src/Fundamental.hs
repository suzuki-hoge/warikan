module Fundamental
  ( Money(..)
  , ($+$)
  , ($*$)
  , DateTime
  ) where

import Data.String (IsString(..))

--
-- Money
--

newtype Money = Money Int deriving (Show, Eq)

($+$) :: Money -> Money -> Money
Money i1 $+$ Money i2 = Money $ i1 + i2

($*$) :: Money -> Int -> Money
Money i1 $*$ i2 = Money $ i1 * i2

--
-- NonEmptyString
--

newtype NonEmptyString = NonEmptyString String deriving (Show, Eq)

instance IsString NonEmptyString where
  fromString = NonEmptyString

--
-- DateTime
--

newtype DateTime = DateTime String deriving (Show, Eq)

instance IsString DateTime where
  fromString = DateTime
