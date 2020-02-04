module Domain.Type where


newtype Name = Name String deriving (Show, Eq)

data MemberSection = MemberSection Name Section deriving (Show, Eq)

data Section = L | M | S deriving (Show, Eq)

data MemberPercent = MemberPercent Name Percent deriving (Show, Eq)

newtype Percent = Percent Int deriving (Show, Eq)

newtype MemberCount = MemberCount Int deriving (Show, Eq)

data Bill = Bill Name Int deriving (Show, Eq)

newtype Amount = Amount Int deriving (Show, Eq)

newtype Sharing = Sharing Int deriving (Show, Eq)

data Missing = Missing deriving (Show, Eq)

data Excessing = Excessing deriving (Show, Eq)

data FractionAmount = MissingAmount Int | ExcessingAmount Int deriving (Show, Eq)

class Fraction a where
  makeFraction :: a -> Amount -> MemberCount -> (Sharing, FractionAmount)

instance Fraction Missing where
  makeFraction _ (Amount a) (MemberCount mc) = (Sharing $ a - (a `div` 100) `mod` mc * 100, MissingAmount $ (a `div` 100) `mod` mc * 100)

instance Fraction Excessing where
  makeFraction _ (Amount a) (MemberCount mc) = (Sharing $ (a + mc * 100) `div` 100 `div` mc * mc * 100, ExcessingAmount $ ((a + mc * 100) `div` 100 `div` mc * mc * 100) - a)

data Accumulator = Accumulator deriving (Show, Eq)

data Secretary = Secretary deriving (Show, Eq)

class Adjuster a where
  adjust :: a -> FractionAmount -> Bill

instance Adjuster Accumulator where
  adjust _ (MissingAmount n) = Bill (Name "Accumulator") n
  adjust _ (ExcessingAmount n) = Bill (Name "Accumulator") n

instance Adjuster Secretary where
  adjust _ (MissingAmount n) = Bill (Name "Secretary") n
  adjust _ (ExcessingAmount n) = Bill (Name "Secretary") n
