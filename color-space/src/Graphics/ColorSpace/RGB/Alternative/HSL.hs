{-# LANGUAGE UndecidableInstances #-}
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
{-# LANGUAGE ViewPatterns #-}
-- |
-- Module      : Graphics.ColorSpace.RGB.Alternative.HSL
-- Copyright   : (c) Alexey Kuleshevich 2018-2019
-- License     : BSD3
-- Maintainer  : Alexey Kuleshevich <lehins@yandex.ru>
-- Stability   : experimental
-- Portability : non-portable
--
module Graphics.ColorSpace.RGB.Alternative.HSL
  ( pattern PixelHSL
  , pattern PixelHSLA
  , pattern PixelH360SI
  , HSL
  , Pixel(HSL)
  , module Graphics.ColorSpace
  ) where

import Data.Coerce
import Data.Typeable
import Foreign.Storable
import Graphics.ColorModel.Alpha
import qualified Graphics.ColorModel.HSL as CM
import Graphics.ColorModel.Internal
import Graphics.ColorSpace

-- | `HSL` representation for some (@`RedGreenBlue` cs i@) color space
data HSL cs

-- | `HSL` representation for some (@`RedGreenBlue` cs i@) color space
newtype instance Pixel (HSL cs) e = HSL (Pixel CM.HSL e)

-- | `HSL` representation for some (@`RedGreenBlue` cs i@) color space
deriving instance Eq e => Eq (Pixel (HSL cs) e)
-- | `HSL` representation for some (@`RedGreenBlue` cs i@) color space
deriving instance Ord e => Ord (Pixel (HSL cs) e)
-- | `HSL` representation for some (@`RedGreenBlue` cs i@) color space
deriving instance Functor (Pixel (HSL cs))
-- | `HSL` representation for some (@`RedGreenBlue` cs i@) color space
deriving instance Applicative (Pixel (HSL cs))
-- | `HSL` representation for some (@`RedGreenBlue` cs i@) color space
deriving instance Foldable (Pixel (HSL cs))
-- | `HSL` representation for some (@`RedGreenBlue` cs i@) color space
deriving instance Traversable (Pixel (HSL cs))
-- | `HSL` representation for some (@`RedGreenBlue` cs i@) color space
deriving instance Storable e => Storable (Pixel (HSL cs) e)

-- | `HSL` representation for some (@`RedGreenBlue` cs i@) color space
instance ColorModel cs e => Show (Pixel (HSL cs) e) where
  showsPrec _ = showsColorModel

-- | Constructor for an RGB color space in an alternative HSL color model
pattern PixelHSL :: e -> e -> e -> Pixel (HSL cs) e
pattern PixelHSL h s i = HSL (CM.PixelHSL h s i)
{-# COMPLETE PixelHSL #-}

-- | Constructor for @HSL@ with alpha channel.
pattern PixelHSLA :: e -> e -> e -> e -> Pixel (Alpha (HSL cs)) e
pattern PixelHSLA h s i a = Alpha (HSL (CM.PixelHSL h s i)) a
{-# COMPLETE PixelHSLA #-}


-- | Constructor for an RGB color space in an alternative HSL color model. Difference from
-- `PixelHSL` is that the hue is specified in 0 to 360 degree range, rather than 0 to
-- 1. Note, that this is not checked.
pattern PixelH360SI :: RealFloat e => e -> e -> e -> Pixel (HSL cs) e
pattern PixelH360SI h s i <- PixelHSL ((* 360) -> h) s i where
        PixelH360SI h s i = PixelHSL (h / 360) s i
{-# COMPLETE PixelH360SI #-}

-- | `HSL` representation for some (@`RedGreenBlue` cs i@) color space
instance ColorModel cs e => ColorModel (HSL cs) e where
  type Components (HSL cs) e = (e, e, e)
  toComponents = toComponents . coerce
  {-# INLINE toComponents #-}
  fromComponents = coerce . fromComponents
  {-# INLINE fromComponents #-}
  showsColorModelName _ = ("HSL" ++)


-- | `HSL` representation for some (@`RedGreenBlue` cs i@) color space
instance (Typeable cs, ColorSpace cs e, RedGreenBlue cs i) => ColorSpace (HSL cs) e where
  type BaseColorSpace (HSL cs) = cs
  toBaseColorSpace = mkPixelRGB . fmap fromDouble . CM.hsl2rgb . fmap toDouble . coerce
  {-# INLINE toBaseColorSpace #-}
  fromBaseColorSpace = coerce . fmap fromDouble . CM.rgb2hsl . fmap toDouble . unPixelRGB
  {-# INLINE fromBaseColorSpace #-}
  toPixelXYZ = toPixelXYZ . toBaseColorSpace
  {-# INLINE toPixelXYZ #-}
  fromPixelXYZ = fromBaseColorSpace . fromPixelXYZ
  {-# INLINE fromPixelXYZ #-}
  showsColorSpaceName _ = showsColorSpaceName (pure 0 :: Pixel cs e)
