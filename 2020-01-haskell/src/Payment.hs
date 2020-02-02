{-# LANGUAGE TupleSections #-}

module Payment
  ( BillingAmount(..)
  , SharingAmount(..)
  , FractionAmount(..)
  , AdjustingUnitCount(..)
  , AdjustingUnitAmount(..)
  , PaymentAmount(..)
  , PaymentSection(..)
  , PaymentError(..)
  , DivideNumber(..)
  , calculate
  , divide
  , adjustByUnit
  , sharing
  , (<++)
  ) where

import Fundamental
import Data.List (nub)

--
-- Types
--

newtype BillingAmount = BillingAmount Money deriving (Show, Eq)

newtype SharingAmount = SharingAmount Money deriving (Show, Eq)

newtype FractionAmount = FractionAmount Money deriving (Show, Eq)

newtype AdjustingUnitCount = AdjustingUnitCount Int deriving (Show, Eq)

newtype AdjustingUnitAmount = AdjustingUnitAmount Money deriving (Show, Eq)

newtype PaymentAmount = PaymentAmount Money deriving (Show, Eq)

newtype DivideNumber = DivideNumber Int deriving (Show, Eq)

--
-- Sections
--

data PaymentSection = More | Normal | Less deriving (Show, Eq)

--
-- Errors
--

data PaymentError = UnsharableAdjustingUnitAmount | TooLargeAdjustingUnitAmount deriving (Show, Eq)

--
-- Functions
--

calculate :: BillingAmount -> [PaymentSection] -> AdjustingUnitAmount -> Either PaymentError ([(PaymentSection, PaymentAmount)], FractionAmount)
calculate billingAmount paymentSections adjustingUnitAmount = do
  let divideNumber = DivideNumber $ length paymentSections
  (sharingAmount, fractionAmount) <- divide billingAmount divideNumber adjustingUnitAmount
  let units = adjustByUnit paymentSections
  (, fractionAmount) <$> sharing sharingAmount adjustingUnitAmount divideNumber units
  

divide :: BillingAmount -> DivideNumber -> AdjustingUnitAmount -> Either PaymentError (SharingAmount, FractionAmount)
divide (BillingAmount (Money ba)) (DivideNumber dn) (AdjustingUnitAmount (Money aua)) = case ba `div` dn `div` aua * dn * aua of
  0       -> Left  UnsharableAdjustingUnitAmount
  sharing -> Right (SharingAmount $ Money sharing, FractionAmount $ Money $ ba - sharing)


adjustByUnit :: [PaymentSection] -> [(PaymentSection, AdjustingUnitCount)]
adjustByUnit paymentSections = let
  (pointer, adjuster) = if More `elem` paymentSections then morePresent else moreMissing

  plus = sum . filter (> 0) . map pointer $ paymentSections
  minus = sum . filter (< 0) . map pointer $ paymentSections
  lcm' = lcm plus minus

  in map (adjuster lcm' plus minus) $ nub paymentSections
    where
      morePresent = (point, adjust)
        where
          point More   = 1
          point Normal = -1
          point Less   = -2

          adjust lcm' plus _     More   = (More,   AdjustingUnitCount $ lcm' `div` plus)
          adjust lcm' _    minus Normal = (Normal, AdjustingUnitCount $ lcm' `div` minus)
          adjust lcm' _    minus Less   = (Less,   AdjustingUnitCount $ lcm' `div` minus * 2)

      moreMissing = (point, adjust)
        where
          point Normal = 1
          point Less   = -1

          adjust lcm' plus _     Normal = (Normal, AdjustingUnitCount $ lcm' `div` plus)
          adjust lcm' _    minus Less   = (Less,   AdjustingUnitCount $ lcm' `div` minus)


sharing :: SharingAmount -> AdjustingUnitAmount -> DivideNumber -> [(PaymentSection, AdjustingUnitCount)] -> Either PaymentError [(PaymentSection, PaymentAmount)]
sharing (SharingAmount (Money sa)) adjustingUnitAmount (DivideNumber dn) units = let
  ave = Money $ sa `div` dn
  fixed = map (mapR (fix ave adjustingUnitAmount)) units
  in if all (>=0) $ map (snd . mapR asInt) fixed then Right fixed  else Left TooLargeAdjustingUnitAmount
    where
      fix :: Money -> AdjustingUnitAmount -> AdjustingUnitCount -> PaymentAmount
      fix ave (AdjustingUnitAmount aua) (AdjustingUnitCount auc) = PaymentAmount $ aua $*$ auc $+$ ave

      asInt :: PaymentAmount -> Int
      asInt (PaymentAmount (Money i)) = i
      

(<++) :: PaymentAmount -> FractionAmount -> PaymentAmount
PaymentAmount m1 <++ FractionAmount m2 = PaymentAmount $ m1 $+$ m2
