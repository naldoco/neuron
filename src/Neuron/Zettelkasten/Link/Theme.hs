{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE ViewPatterns #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Neuron.Zettelkasten.Link.Theme
  ( ZettelsView (..),
    ZettelView,
    LinkTheme (..),
    zettelsViewFromURI,
    linkThemeFromURI,
  )
where

import Control.Monad.Except
import Relude
import qualified Text.URI as URI
import Text.URI.QQ (queryKey)

data ZettelsView = ZettelsView
  { zettelsViewLinkTheme :: LinkTheme,
    zettelsViewGroupByTag :: Bool
  }
  deriving (Eq, Show, Ord)

type ZettelView = LinkTheme

data LinkTheme
  = LinkTheme_Default
  | LinkTheme_Simple
  | LinkTheme_WithDate
  deriving (Eq, Show, Ord)

zettelsViewFromURI :: MonadError Text m => URI.URI -> m ZettelsView
zettelsViewFromURI uri =
  ZettelsView
    <$> linkThemeFromURI uri
    <*> pure (hasQueryFlag [queryKey|grouped|] uri)

linkThemeFromURI :: MonadError Text m => URI.URI -> m LinkTheme
linkThemeFromURI uri =
  fmap (fromMaybe LinkTheme_Default) $ case getQueryParam [queryKey|linkTheme|] uri of
    Just "default" -> pure $ Just LinkTheme_Default
    Just "simple" -> pure $ Just LinkTheme_Simple
    Just "withDate" -> pure $ Just LinkTheme_WithDate
    Nothing -> pure Nothing
    _ -> throwError "Invalid value for linkTheme"

getQueryParam :: URI.RText 'URI.QueryKey -> URI.URI -> Maybe Text
getQueryParam k uri =
  listToMaybe $ catMaybes $ flip fmap (URI.uriQuery uri) $ \case
    URI.QueryFlag _ -> Nothing
    URI.QueryParam key (URI.unRText -> val) ->
      if key == k
        then Just val
        else Nothing

hasQueryFlag :: URI.RText 'URI.QueryKey -> URI.URI -> Bool
hasQueryFlag k uri =
  fromMaybe False $ listToMaybe $ catMaybes $ flip fmap (URI.uriQuery uri) $ \case
    URI.QueryFlag key ->
      if key == k
        then Just True
        else Nothing
    _ -> Nothing
