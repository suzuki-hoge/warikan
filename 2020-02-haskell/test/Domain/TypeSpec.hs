module Domain.TypeSpec (spec) where

import Test.Hspec

import Domain.Type


spec :: Spec
spec = do
  describe "missing fraction" $
    it "share 3,000 with 7 members is 2,800, and 200 missing." $
      makeFraction Missing (Amount 3000) (MemberCount 7) `shouldBe` (Sharing 2800, MissingAmount 200)

  describe "excessing fraction" $
    it "share 3,000 with 7 members is 3,500, and 500 excessing." $
      makeFraction Excessing (Amount 3000) (MemberCount 7) `shouldBe` (Sharing 3500, ExcessingAmount 500)
