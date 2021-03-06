{-# LANGUAGE GADTs #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Neuron.Zettelkasten.Tag
  ( Tag (..),
    TagPattern (unTagPattern),
    mkTagPattern,
    tagMatch,
    tagMatchAny,
  )
where

import Data.Aeson
import Relude
import System.FilePattern

newtype Tag = Tag {unTag :: Text}
  deriving (Eq, Ord, Show, ToJSON, FromJSON)

newtype TagPattern = TagPattern {unTagPattern :: FilePattern}
  deriving (Eq, Show)

mkTagPattern :: Text -> TagPattern
mkTagPattern =
  TagPattern . toString

tagMatch :: TagPattern -> Tag -> Bool
tagMatch (TagPattern pat) (Tag tag) =
  pat ?== toString tag

tagMatchAny :: [TagPattern] -> Tag -> Bool
tagMatchAny pats tag =
  -- TODO: Use step from https://hackage.haskell.org/package/filepattern-0.1.2/docs/System-FilePattern.html#v:step
  -- for efficient matching.
  any (`tagMatch` tag) pats
