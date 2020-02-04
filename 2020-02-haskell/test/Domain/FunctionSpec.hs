module Domain.FunctionSpec (spec) where

import Test.Hspec

import Domain.Function
import Domain.Type


spec :: Spec
spec = do
  describe "demand" $ do
    it "2,000 / 50%, 30%, 20% and pay remains by secretary is 900, 540, 360 and 200 missing." $ do
      let mps = [ MemberPercent (Name "John") (Percent 50)
                , MemberPercent (Name "Jane") (Percent 30)
                , MemberPercent (Name "Jack") (Percent 20)
                ]
      let exp = [ Bill (Name "John") 900
                , Bill (Name "Jane") 540
                , Bill (Name "Jack") 360
                , Bill (Name "Secretary") 200
                ]
      demand Secretary Missing (Amount 2000) mps `shouldBe` exp

    it "2,000 / 50%, 30%, 20% and accumulate for next party is 1050, 630, 420 and 100 excessing." $ do
      let mps = [ MemberPercent (Name "John") (Percent 50)
                , MemberPercent (Name "Jane") (Percent 30)
                , MemberPercent (Name "Jack") (Percent 20)
                ]
      let exp = [ Bill (Name "John") 1050
                , Bill (Name "Jane") 630
                , Bill (Name "Jack") 420
                , Bill (Name "Accumulator") 100
                ]
      demand Accumulator Excessing (Amount 2000) mps `shouldBe` exp
