-- | Application types.
module Application.Type where

data Error = MemberError     -- ^ Mismatch in MemberSection names and MemberPercent names.
           | PercentError    -- ^ Sum of percent does not 100%.
           | SectionError    -- ^ Specified percent is not in section range.
           deriving (Show, Eq)
