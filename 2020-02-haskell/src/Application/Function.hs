module Application.Function where

import Data.List ( sort )

import Application.Type
import Domain
import Fundamental

apply :: (Adjuster a, Fraction f) => MemberSection -> MemberSection -> [MemberSection] -> Amount -> a -> f -> [MemberPercent] -> Either Error [Bill]
apply ms1 ms2 mss amount adjuster fraction mps = guard ([ms1, ms2] ++ mss) mps <&> demand adjuster fraction amount
  where
    guard :: [MemberSection] -> [MemberPercent] -> Either Error [MemberPercent]
    guard mss mps = let
      snames = map (\(MemberSection name _) -> name) mss
      pnames = map (\(MemberPercent name _) -> name) mps
      ss = map (\(MemberSection _ section) -> section) mss
      ps = map (\(MemberPercent _ (Percent p)) -> p) mps
      zipped = zip ss ps
      sides = concatMap id [ last' $ sort $ concatMap (\(s, p) -> if s == S then [p] else []) zipped
              , head' $ sort $ concatMap (\(s, p) -> if s == M then [p] else []) zipped
              , last' $ sort $ concatMap (\(s, p) -> if s == M then [p] else []) zipped
              , head' $ sort $ concatMap (\(s, p) -> if s == L then [p] else []) zipped
              ]
      in
      if snames /= pnames    then Left MemberMismatch  else
      if sum ps /= 100       then Left PercentMismatch else
      if sides /= sort sides then Left SectionMismatch else
      Right mps
