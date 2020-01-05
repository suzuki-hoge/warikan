module FundamentalSpec (spec) where

import Test.Hspec

import Fundamental


--
-- Spec
--


spec :: Spec
spec = do
  describe "money addition" $ do
    it "3 $+$  5 ->  8" $
      Money 3 $+$ Money 5 `shouldBe` Money 8
      
    it "3 $+$  0 ->  3" $
      Money 3 $+$ Money 0 `shouldBe` Money 3
      
    it "3 $+$ -5 -> -2" $
      Money 3 $+$ Money (-5) `shouldBe` Money (-2)
      
      
  describe "money multiplication" $ do
    it "3 $*$  5 -> 15" $
      Money 3 $*$ 5 `shouldBe` Money 15
      
    it "3 $*$  0 ->  0" $
      Money 3 $*$ 0 `shouldBe` Money 0
      
    it "3 $*$ -5 -> 15" $
      Money 3 $*$ (-5) `shouldBe` Money (-15)
      
      
  describe "mapR" $
    it "mapR (+2) (2, 3) = (2, 5)" $
      mapR (+2) (2, 3) `shouldBe` (2, 5)
      
      
  describe "mapL" $
    it "mapR (+2) (2, 3) = (4, 3)" $
      mapL (+2) (2, 3) `shouldBe` (4, 3)
