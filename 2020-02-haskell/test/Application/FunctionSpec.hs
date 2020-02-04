module Application.FunctionSpec (spec) where

import Test.Hspec

import Application.Function
import Application.Type
import Domain.Type


spec :: Spec
spec = do
  describe "apply failure" $ do
    it "set [John, Jane, Jack] but apply with [John, Jane] is member mismatch." $ do
      let ms1 = MemberSection (Name "John") L
      let ms2 = MemberSection (Name "Jane") M
      let ms3 = MemberSection (Name "Jack") S

      let mp1 = MemberPercent (Name "John") (Percent 60)
      let mp2 = MemberPercent (Name "Jane") (Percent 40)

      apply ms1 ms2 [ms3] (Amount 2000) Accumulator Excessing [mp1, mp2] `shouldBe` Left MemberMismatch

    it "apply with [50%, 40%] is percent mismatch." $ do
      let ms1 = MemberSection (Name "John") L
      let ms2 = MemberSection (Name "Jane") M

      let mp1 = MemberPercent (Name "John") (Percent 50)
      let mp2 = MemberPercent (Name "Jane") (Percent 40)

      apply ms1 ms2 [] (Amount 2000) Accumulator Excessing [mp1, mp2] `shouldBe` Left PercentMismatch

    it "set [L, M, S] but apply with [50%, 20%, 30%] is section mismatch." $ do
      let ms1 = MemberSection (Name "John") L
      let ms2 = MemberSection (Name "Jane") M
      let ms3 = MemberSection (Name "Jack") S

      let mp1 = MemberPercent (Name "John") (Percent 50)
      let mp2 = MemberPercent (Name "Jane") (Percent 20)
      let mp3 = MemberPercent (Name "Jack") (Percent 30)

      apply ms1 ms2 [ms3] (Amount 2000) Accumulator Excessing [mp1, mp2, mp3] `shouldBe` Left SectionMismatch
