{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeFamilies #-}
-- |
-- Module      : Graphics.ColorSpace.RGB.Derived.AdobeRGB
-- Copyright   : (c) Alexey Kuleshevich 2018-2019
-- License     : BSD3
-- Maintainer  : Alexey Kuleshevich <lehins@yandex.ru>
-- Stability   : experimental
-- Portability : non-portable
--
module Graphics.ColorSpace.RGB.Derived.AdobeRGB
  ( pattern PixelRGB
  , pattern PixelRGBA
  , RGB
  , AdobeRGB.primaries
  , AdobeRGB.transfer
  , AdobeRGB.itransfer
  ) where

import Data.Coerce
import Data.Proxy
import Foreign.Storable
import Graphics.ColorModel.Alpha
import Graphics.ColorModel.Internal
import qualified Graphics.ColorModel.RGB as CM
import Graphics.ColorSpace.Internal
import qualified Graphics.ColorSpace.RGB.AdobeRGB as AdobeRGB
import Graphics.ColorSpace.RGB.Internal


-- | The most common @AdobeRGB@ color space with an arbitrary illuminant
data RGB (i :: k)

-- | Adobe`RGB` color space (derived)
newtype instance Pixel (RGB i) e = RGB (Pixel CM.RGB e)

-- | Constructor for @AdobeRGB@ color space with an arbitrary illuminant
pattern PixelRGB :: e -> e -> e -> Pixel (RGB i) e
pattern PixelRGB r g b = RGB (CM.PixelRGB r g b)
{-# COMPLETE PixelRGB #-}

-- | Constructor for @AdobeRGB@ with alpha channel.
pattern PixelRGBA :: e -> e -> e -> e -> Pixel (Alpha (RGB i)) e
pattern PixelRGBA r g b a = Alpha (RGB (CM.PixelRGB r g b)) a
{-# COMPLETE PixelRGBA #-}


-- | Adobe`RGB` color space (derived)
deriving instance Eq e => Eq (Pixel (RGB i) e)
-- | Adobe`RGB` color space (derived)
deriving instance Ord e => Ord (Pixel (RGB i) e)
-- | Adobe`RGB` color space (derived)
deriving instance Functor (Pixel (RGB i))
-- | Adobe`RGB` color space (derived)
deriving instance Applicative (Pixel (RGB i))
-- | Adobe`RGB` color space (derived)
deriving instance Foldable (Pixel (RGB i))
-- | Adobe`RGB` color space (derived)
deriving instance Traversable (Pixel (RGB i))
-- | Adobe`RGB` color space (derived)
deriving instance Storable e => Storable (Pixel (RGB i) e)

-- | Adobe`RGB` color space (derived)
instance (Illuminant i, Elevator e) => Show (Pixel (RGB (i :: k)) e) where
  showsPrec _ = showsColorModel

-- | Adobe`RGB` color space (derived)
instance (Illuminant i, Elevator e) => ColorModel (RGB (i :: k)) e where
  type Components (RGB i) e = (e, e, e)
  toComponents = toComponents . coerce
  {-# INLINE toComponents #-}
  fromComponents = coerce . fromComponents
  {-# INLINE fromComponents #-}
  showsColorModelName = showsColorModelName . unPixelRGB

-- | Adobe`RGB` color space (derived)
instance (Illuminant i, Elevator e) => ColorSpace (RGB (i :: k)) e where
  type BaseColorSpace (RGB i) = RGB i
  toBaseColorSpace = id
  {-# INLINE toBaseColorSpace #-}
  fromBaseColorSpace = id
  {-# INLINE fromBaseColorSpace #-}
  toPixelXYZ = rgb2xyz
  {-# INLINE toPixelXYZ #-}
  fromPixelXYZ = xyz2rgb
  {-# INLINE fromPixelXYZ #-}
  showsColorSpaceName _ = ('s':) . showsType (Proxy :: Proxy (RGB i))

-- | Adobe`RGB` color space (derived)
instance Illuminant i => RedGreenBlue RGB i where
  chromaticity = AdobeRGB.primaries
  ecctf = fmap AdobeRGB.transfer
  {-# INLINE ecctf #-}
  dcctf = fmap AdobeRGB.itransfer
  {-# INLINE dcctf #-}