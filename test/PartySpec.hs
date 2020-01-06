{-# LANGUAGE OverloadedStrings #-}

module PartySpec (spec) where

import Test.Hspec

import Party
import Payment
import Fundamental


--
-- Helper
--

pn = ParticipantName
ba = BillingAmount . Money
aua = AdjustingUnitAmount . Money
pa = PaymentAmount . Money
-- Participants
p1 = Participant (pn "p1") Secretary
p2 = Participant (pn "p2") NotSecretary
p3 = Participant (pn "p3") NotSecretary
p4 = Participant (pn "p4") NotSecretary
p5 = Participant (pn "p5") NotSecretary
p6 = Participant (pn "p6") NotSecretary
-- Party
p = Party (PartyName "new year") (PartyHoldAt "2019/01/01") PaybackToSecretary

--
-- Spec
--

spec :: Spec
spec = do
  describe "plan, add / remove participants, change adjusting unit amount" $
    it "plan, add add remove add, change" $ do
      let planned = plan (PartyName "new year") (PartyHoldAt "2019/01/01") PaybackToSecretary (pn "p1", More) (ba 60000) (aua 1000)
      
      planned `shouldBe` p [p1 More] (ba 60000) (aua 1000)
      
      let added1 = add planned (p2 Normal)
      
      added1 `shouldBe` p [p1 More, p2 Normal] (ba 60000) (aua 1000)
      
      let added2 = add added1 (p3 Less)
      
      added2 `shouldBe` p [p1 More, p2 Normal, p3 Less] (ba 60000) (aua 1000)
      
      let removed = remove added2 (pn "p3")
      
      removed `shouldBe` p [p1 More, p2 Normal] (ba 60000) (aua 1000)
      
      let added4 = add removed (p4 Normal)
      
      added4 `shouldBe` p [p1 More, p2 Normal, p4 Normal] (ba 60000) (aua 1000)
      
      let changed = changeAdjustingUnitAmount added4 (aua 500)
      
      changed `shouldBe` p [p1 More, p2 Normal, p4 Normal] (ba 60000) (aua 500)
      
  describe "demand" $ do
    it "calculate 60000 with More   ( Secretary ), More,   More,   Normal, Less,   Less   adjust by 1000 = 15000, 15000, 15000,  7000,  4000,  4000" $ do
      let party = p [p1 More, p2 More, p3 More, p4 Normal, p5 Less, p6 Less] (ba 60000) (aua 1000)

      demand party `shouldBe` Right [(pn "p1", pa 15000), (pn "p2", pa 15000), (pn "p3", pa 15000), (pn "p4", pa 7000), (pn "p5", pa 4000), (pn "p6", pa 4000)]
      
    it "calculate 65000 with More   ( Secretary ), More,   More,   Normal, Less,   Less   adjust by 1000 = 20000, 15000, 15000,  7000,  4000,  4000" $ do
      let party = p [p1 More, p2 More, p3 More, p4 Normal, p5 Less, p6 Less] (ba 65000) (aua 1000)

      demand party `shouldBe` Right [(pn "p1", pa 20000), (pn "p2", pa 15000), (pn "p3", pa 15000), (pn "p4", pa 7000), (pn "p5", pa 4000), (pn "p6", pa 4000)]
      
    it "calculate 65000 with More   ( Secretary ), More,   More,   Normal, Less,   Less   adjust by  500 = 15000, 13000, 13000,  9000,  7500,  4500" $ do
      let party = p [p1 More, p2 More, p3 More, p4 Normal, p5 Less, p6 Less] (ba 65000) (aua 500)

      demand party `shouldBe` Right [(pn "p1", pa 15000), (pn "p2", pa 13000), (pn "p3", pa 13000), (pn "p4", pa 9000), (pn "p5", pa 7500), (pn "p6", pa 7500)]

    it "calculate 60000 with Normal ( Secretary ), Normal, Normal, Normal, Normal, Normal adjust by 1000 = 10000, 10000, 10000, 10000, 10000, 10000" $ do
      let party = p [p1 Normal, p2 Normal, p3 Normal, p4 Normal, p5 Normal, p6 Normal] (ba 60000) (aua 1000)

      demand party `shouldBe` Right [(pn "p1", pa 10000), (pn "p2", pa 10000), (pn "p3", pa 10000), (pn "p4", pa 10000), (pn "p5", pa 10000), (pn "p6", pa 10000)]
