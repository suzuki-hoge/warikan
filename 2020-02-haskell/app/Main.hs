module Main where

import Application
import Domain

main :: IO ()
main = do
  let ms1 = MemberSection (Name "John") L
  let ms2 = MemberSection (Name "Jane") M
  let ms3 = MemberSection (Name "Jack") S
  let amount = Amount 1900
  let mp1 = MemberPercent (Name "John") (Percent 50)
  let mp2 = MemberPercent (Name "Jane") (Percent 30)
  let mp3 = MemberPercent (Name "Jack") (Percent 20)

  print $ apply ms1 ms2 [ms3] amount Accumulator Missing [mp1, mp2, mp3]
