-- | Domain functions.
module Domain.Function where

import Domain.Type
import Fundamental.Function


-- | Fix bills.
demand :: (Adjuster adjuster, Fraction fraction) => adjuster -> fraction -> Amount -> [MemberPercent] -> [Bill]
demand adjuster fraction amount mps =
  count mps
  |> makeFraction fraction amount
  ||> (share mps, adjust adjuster)
  >< (\(bs, b) -> bs ++ [b])
      where
        count :: [MemberPercent] -> MemberCount
        count = MemberCount . length

        share :: [MemberPercent] -> Sharing -> [Bill]
        share mps (Sharing s) = map (\(MemberPercent name (Percent p)) -> Bill name (s * p `div` 100)) mps
