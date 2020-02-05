-- | Domain types.
module Domain.Type where

-- | use like id in this work, so you must keep uniqueness.
newtype Name = Name String deriving (Show, Eq)

data MemberSection = MemberSection Name Section deriving (Show, Eq)

data Section = L    -- ^ Large
             | M    -- ^ Medium
             | S    -- ^ Small
             deriving (Show, Eq)

data MemberPercent = MemberPercent Name Percent deriving (Show, Eq)

newtype Percent = Percent Int deriving (Show, Eq)

newtype MemberCount = MemberCount Int deriving (Show, Eq)

data Bill = Bill Name Int deriving (Show, Eq)

newtype Amount = Amount Int deriving (Show, Eq)

newtype Sharing = Sharing Int deriving (Show, Eq)

-- | Fraction amount calculation method.
class Fraction a where
  makeFraction :: a -> Amount -> MemberCount -> (Sharing, FractionAmount)

-- | Fraction amount method that collect slightly and "Missing".
data Missing = Missing deriving (Show, Eq)

-- | Fraction amount method that collect overly and "Excessing".
data Excessing = Excessing deriving (Show, Eq)

instance Fraction Missing where
  makeFraction _ (Amount a) (MemberCount mc) = (Sharing $ a - (a `div` 100) `mod` mc * 100, MissingAmount $ (a `div` 100) `mod` mc * 100)

instance Fraction Excessing where
  makeFraction _ (Amount a) (MemberCount mc) = (Sharing $ (a + mc * 100) `div` 100 `div` mc * mc * 100, ExcessingAmount $ ((a + mc * 100) `div` 100 `div` mc * mc * 100) - a)

data FractionAmount = MissingAmount Int | ExcessingAmount Int deriving (Show, Eq)

fractionAmountValue :: FractionAmount -> Int
fractionAmountValue (MissingAmount n) = n
fractionAmountValue (ExcessingAmount n) = n

-- | Accumulate for next party.
data Accumulator = Accumulator deriving (Show, Eq)

-- | Entrust fraction amount to secretary.
data Secretary = Secretary deriving (Show, Eq)

-- | Fix Bill for fraction amount.
class Adjuster a where
  adjust :: a -> FractionAmount -> Bill

instance Adjuster Accumulator where
  adjust _ fractionAmount = Bill (Name "Accumulator") (fractionAmountValue fractionAmount)

instance Adjuster Secretary where
  adjust _ fractionAmount = Bill (Name "Secretary") (fractionAmountValue fractionAmount)
