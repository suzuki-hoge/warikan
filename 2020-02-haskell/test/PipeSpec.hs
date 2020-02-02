module PipeSpec (spec) where

import Test.Hspec

import Pipe


--
-- Spec
--


spec :: Spec
spec = do
  describe "single pipe" $
    it "3 |> (+2) == 5" $
      3 |> (+2) `shouldBe` 5

  describe "double pipe" $
    it "(3, 5) ||> ((*2), (+3)) == (6, 8)" $
      (3, 5) ||> ((*2), (+3)) `shouldBe` (6, 8)

  describe "fold" $
    it "(3, 5) >< \\(a, b) -> a + b == 8" $
      (3, 5) >< \(a, b) -> a + b `shouldBe` 8
