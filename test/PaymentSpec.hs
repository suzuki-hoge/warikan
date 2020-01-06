module PaymentSpec (spec) where

import Test.Hspec

import Payment
import Fundamental


--
-- Helper
--

ba = BillingAmount . Money
aua = AdjustingUnitAmount . Money
sa = SharingAmount . Money
fa = FractionAmount . Money
pa = PaymentAmount . Money
dn = DivideNumber
-- positive counts
mpc i = (More,   AdjustingUnitCount i)
npc i = (Normal, AdjustingUnitCount i)
lpc i = (Less,   AdjustingUnitCount i)
-- negative counts
nnc i = (Normal, AdjustingUnitCount (-i))
lnc i = (Less,   AdjustingUnitCount (-i))
-- zero counts
m0c = (More,   AdjustingUnitCount 0)
n0c = (Normal, AdjustingUnitCount 0)
l0c = (Less,   AdjustingUnitCount 0)
-- payment amounts
mpa i = (More,   PaymentAmount $ Money i)
npa i = (Normal, PaymentAmount $ Money i)
lpa i = (Less,   PaymentAmount $ Money i)

--
-- Spec
--

spec :: Spec
spec = do
  describe "divide" $ do
    it "1000 / 3 adjust by 100 =  900 + 100" $
      divide (ba 1000) (dn 3) (aua 100) `shouldBe` Right (sa 900, fa 100)

    it "1199 / 3 adjust by 100 =  900 + 299" $
      divide (ba 1199) (dn 3) (aua 100) `shouldBe` Right (sa 900, fa 299)

    it "1200 / 3 adjust by 100 = 1200 +   0" $
      divide (ba 1200) (dn 3) (aua 100) `shouldBe` Right (sa 1200, fa 0)

    it "1199 / 3 adjust by  10 = 1170 +  29" $
      divide (ba 1199) (dn 3) (aua 10) `shouldBe` Right (sa 1170, fa 29)

  describe "divide ( unsharable error )" $
    it "1200 / 3 adjust by 500" $
      divide (ba 1200) (dn 3) (aua 500) `shouldBe` Left UnsharableAdjustingUnitAmount


  describe "adjust on all sections" $ do
    it "M, N, L          = (M, 3), (N, -1), (L, -2)" $
      adjustByUnit [More, Normal, Less] `shouldBe` [mpc 3, nnc 1, lnc 2]

    it "M, M, M, N, L    = (M, 1), (N, -1), (L, -2)" $
      adjustByUnit [More, More, More, Normal, Less] `shouldBe` [mpc 1, nnc 1, lnc 2]

    it "M, M, M, N, L, L = (M, 5), (N, -3), (L, -6)" $
      adjustByUnit [More, More, More, Normal, Less, Less] `shouldBe` [mpc 5, nnc 3, lnc 6]
      
    it "M, N, N, L, L    = (M, 6), (N, -1), (L, -2)" $
      adjustByUnit [More, Normal, Normal, Less, Less] `shouldBe` [mpc 6, nnc 1, lnc 2]


  describe "adjust on 2 sections" $ do
    it "M, N             = (M, 1), (N, -1)" $
      adjustByUnit [More, Normal] `shouldBe` [mpc 1, nnc 1]

    it "M, L             = (M, 2), (L, -2)" $
      adjustByUnit [More, Less] `shouldBe` [mpc 2, lnc 2]


  describe "adjust on M missings" $ do
    it "N, L             = (N, 1), (L, -1)" $
      adjustByUnit [Normal, Less] `shouldBe` [npc 1, lnc 1]

    it "N, L, L          = (N, 2), (L, -1)" $
      adjustByUnit [Normal, Less, Less] `shouldBe` [npc 2, lnc 1]


  describe "adjust on 1 section" $ do
    it "M                = (M, 0)" $
      adjustByUnit [More] `shouldBe` [m0c]

    it "N                = (N, 0)" $
      adjustByUnit [Normal] `shouldBe` [n0c]

    it "L                = (L, 0)" $
      adjustByUnit [Less] `shouldBe` [l0c]


  describe "sharing" $ do
    it "share   900 with M, N, L          adjust by  100 =   600,    200,   100" $
      sharing (sa 900) (aua 100) (dn 3) [mpc 3, nnc 1, lnc 2] `shouldBe` Right [mpa 600, npa 200, lpa 100]
      
    it "share 60000 with M, M, M, N, L, L adjust by 1000 = 15000,  17000,  4000" $
      sharing (sa 60000) (aua 1000) (dn 6) [mpc 5, nnc 3, lnc 6] `shouldBe` Right [mpa 15000, npa 7000, lpa 4000]


  describe "sharing ( too large adjusting unit amount )" $
    it "share  6000 with M, M, M, N, L, L adjust by 1000" $
      sharing (sa 6000) (aua 1000) (dn 6) [mpc 5, nnc 3, lnc 6] `shouldBe` Left TooLargeAdjustingUnitAmount


  describe "calculate" $ do
    it "calculate   900 with M, N, L          adjust by  100 =   600,   200,   100 and    0 fraction" $
      calculate (ba 900) [More, Normal, Less] (aua 100) `shouldBe` Right ([mpa 600, npa 200, lpa 100], fa 0)

    it "calculate   990 with M, N, L          adjust by  100 =   600,   200,   100 and   90 fraction" $
      calculate (ba 990) [More, Normal, Less] (aua 100) `shouldBe` Right ([mpa 600, npa 200, lpa 100], fa 90)

    it "calculate   990 with M, N, L          adjust by   10 =   330,   290,   280 and    0 fraction" $
      calculate (ba 990) [More, Normal, Less] (aua 10) `shouldBe` Right ([mpa 360, npa 320, lpa 310], fa 0)

    it "calculate   995 with M, N, L          adjust by   10 =   330,   290,   280 and    5 fraction" $
      calculate (ba 995) [More, Normal, Less] (aua 10) `shouldBe` Right ([mpa 360, npa 320, lpa 310], fa 5)

    it "calculate 60000 with M, M, M, N, L, L adjust by 1000 = 15000,  7000,  4000 and    0 fraction" $
      calculate (ba 60000) [More, More, More, Normal, Less, Less] (aua 1000) `shouldBe` Right ([mpa 15000, npa 7000, lpa 4000], fa 0)

    it "calculate 65000 with M, M, M, N, L, L adjust by 1000 = 15000,  7000,  4000 and 5000 fraction" $
      calculate (ba 65000) [More, More, More, Normal, Less, Less] (aua 1000) `shouldBe` Right ([mpa 15000, npa 7000, lpa 4000], fa 5000)

    it "calculate 65000 with M, M, M, N, L, L adjust by  500 = 13000,  9000,  7500 and 2000 fraction" $
      calculate (ba 65000) [More, More, More, Normal, Less, Less] (aua 500) `shouldBe` Right ([mpa 13000, npa 9000, lpa 7500], fa 2000)


  describe "add fraction to payment" $
    it "30 <++ 5 = 35" $
      pa 30 <++ fa 5 `shouldBe` pa 35
