module Fundamental.FunctionSpec (spec) where

import Test.Hspec

import Fundamental.Function


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

  describe "flipped fmap on Either" $ do
    let r = Right 3 :: Either String Int
    let l = Left "foo" :: Either String Int

    it "Right 3 <&> (+2) == Right 5" $
      r <&> (+2) `shouldBe` Right 5

    it "Left foo <&> (+2) == Left foo" $
      l <&> (+2) `shouldBe` Left "foo"

  describe "head or empty" $ do
    it "head' [1, 2] == [1]" $
      head' [1, 2] `shouldBe` [1]

    it "head' [1] == [1]" $
      head' [1] `shouldBe` [1]

    it "head' [] == []" $
      (head' [] :: [Int]) `shouldBe` []

  describe "last or empty" $ do
    it "last' [1, 2] == [2]" $
      last' [1, 2] `shouldBe` [2]

    it "last' [1] == [1]" $
      last' [1] `shouldBe` [1]

    it "last' [] == []" $
      (last' [] :: [Int]) `shouldBe` []
