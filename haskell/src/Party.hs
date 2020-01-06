module Party
  ( Party(..)
  , PartyName(..)
  , PartyHoldAt(..)
  , Participant(..)
  , ParticipantName(..)
  , FractionPolicy(..)
  , ParticipantType(..)
  , plan
  , changeAdjustingUnitAmount
  , add
  , remove
  , demand
  ) where

import Payment
import Fundamental

--
-- Types
--

data Party = Party PartyName PartyHoldAt FractionPolicy [Participant] BillingAmount AdjustingUnitAmount deriving (Show, Eq)

newtype PartyName = PartyName NonEmptyString deriving (Show, Eq)

newtype PartyHoldAt = PartyHoldAt DateTime deriving (Show, Eq)

data Participant = Participant ParticipantName ParticipantType PaymentSection deriving (Show, Eq)

newtype ParticipantName = ParticipantName NonEmptyString deriving (Show, Eq)

--
-- Sections
--

data FractionPolicy = PaybackToSecretary | NextParty deriving (Show, Eq)

data ParticipantType = Secretary | NotSecretary deriving (Show, Eq)

--
-- Functions
--

plan :: PartyName -> PartyHoldAt -> FractionPolicy -> (ParticipantName, PaymentSection) -> BillingAmount -> AdjustingUnitAmount -> Party
plan partyName partyHoldAt fractionPolicy (participantName, paymentSection) = Party partyName partyHoldAt fractionPolicy [Participant participantName Secretary paymentSection]


changeAdjustingUnitAmount :: Party -> AdjustingUnitAmount -> Party
changeAdjustingUnitAmount (Party a b c d e _) = Party a b c d e


add :: Party -> Participant -> Party
add (Party a b c d e f) p = Party a b c (d ++ [p]) e f


remove :: Party -> ParticipantName -> Party
remove (Party a b c d e f) pn = Party a b c (filter ((/= pn) . asParticipantName) d) e f
  where
    asParticipantName (Participant a _ _) = a


demand :: Party -> Either PaymentError [(ParticipantName, PaymentAmount)]
demand (Party _ _ _ participants billingAMount adjustingUnitAmount) = do
  (units, fractionAmount) <- calculate billingAMount (map asPaymentSection participants) adjustingUnitAmount
  return $ map (bind units fractionAmount) participants
  where
    asPaymentSection :: Participant -> PaymentSection
    asPaymentSection (Participant _ _ paymentSection) = paymentSection

    bind :: [(PaymentSection, PaymentAmount)] -> FractionAmount -> Participant -> (ParticipantName, PaymentAmount)
    bind units fractionAmount (Participant participantName participantType paymentSection) = let
      paymentAmount = head . map snd . filter ((== paymentSection) . fst) $ units
      in case participantType of
        Secretary    -> (participantName, paymentAmount <++ fractionAmount)
        NotSecretary -> (participantName, paymentAmount)

