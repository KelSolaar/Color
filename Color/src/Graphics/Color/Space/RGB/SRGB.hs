{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NegativeLiterals #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeFamilies #-}
-- |
-- Module      : Graphics.Color.Space.RGB.SRGB
-- Copyright   : (c) Alexey Kuleshevich 2019-2020
-- License     : BSD3
-- Maintainer  : Alexey Kuleshevich <lehins@yandex.ru>
-- Stability   : experimental
-- Portability : non-portable
--
module Graphics.Color.Space.RGB.SRGB
  ( -- * Constructors for a sRGB color space.
    pattern SRGB
  , pattern ColorSRGB
  , pattern ColorSRGBA
  , SRGB
  , D50
  , D65
  , primaries
  , npmStandard
  , inpmStandard
  , transfer
  , itransfer
  ) where

import Foreign.Storable
import Graphics.Color.Model.Alpha
import Graphics.Color.Model.Internal
import qualified Graphics.Color.Model.RGB as CM
import Graphics.Color.Space.Internal
import Graphics.Color.Space.RGB.Internal
import Graphics.Color.Space.RGB.Luma
import Graphics.Color.Illuminant.ICC.PCS (D50)
import Graphics.Color.Space.RGB.ITU.Rec709 (D65, primaries)

-- | The most common [sRGB](https://en.wikipedia.org/wiki/SRGB) color space with the
-- default `D65` illuminant
data SRGB


newtype instance Color SRGB e = SRGB (Color CM.RGB e)

-- | Constructor for a color in @sRGB@ color space
--
-- @since 0.1.0
pattern ColorSRGB :: e -> e -> e -> Color SRGB e
pattern ColorSRGB r g b = SRGB (CM.ColorRGB r g b)
{-# COMPLETE ColorSRGB #-}

-- | Constructor for a color in @sRGB@ color space with alphs channel
--
-- @since 0.1.0
pattern ColorSRGBA :: e -> e -> e -> e -> Color (Alpha SRGB) e
pattern ColorSRGBA r g b a = Alpha (SRGB (CM.ColorRGB r g b)) a
{-# COMPLETE ColorSRGBA #-}


-- | s`RGB` color space
deriving instance Eq e => Eq (Color SRGB e)
-- | s`RGB` color space
deriving instance Ord e => Ord (Color SRGB e)
-- | s`RGB` color space
deriving instance Functor (Color SRGB)
-- | s`RGB` color space
deriving instance Applicative (Color SRGB)
-- | s`RGB` color space
deriving instance Foldable (Color SRGB)
-- | s`RGB` color space
deriving instance Traversable (Color SRGB)
-- | s`RGB` color space
deriving instance Storable e => Storable (Color SRGB e)

-- | s`RGB` color space
instance Elevator e => Show (Color SRGB e) where
  showsPrec _ = showsColorModel

-- | s`RGB` color space
instance Elevator e => ColorModel SRGB e where
  type Components SRGB e = (e, e, e)
  toComponents = toComponents . unColorRGB
  {-# INLINE toComponents #-}
  fromComponents = mkColorRGB . fromComponents
  {-# INLINE fromComponents #-}

-- | s`RGB` color space
instance Elevator e => ColorSpace SRGB D65 e where
  type BaseModel SRGB = CM.RGB
  toBaseSpace = id
  {-# INLINE toBaseSpace #-}
  fromBaseSpace = id
  {-# INLINE fromBaseSpace #-}
  luminance = rgbLuminance . fmap toRealFloat
  {-# INLINE luminance #-}
  toColorXYZ = rgb2xyz . fmap toRealFloat
  {-# INLINE toColorXYZ #-}
  fromColorXYZ = fmap fromRealFloat . xyz2rgb
  {-# INLINE fromColorXYZ #-}

-- | s`RGB` color space
instance RedGreenBlue SRGB D65 where
  gamut = primaries
  npm = npmStandard
  inpm = inpmStandard
  ecctf = fmap transfer
  {-# INLINE ecctf #-}
  dcctf = fmap itransfer
  {-# INLINE dcctf #-}

instance Luma SRGB where
  rWeight = 0.299
  gWeight = 0.587
  bWeight = 0.114


-- | sRGB normalized primary matrix. This is a helper definition, use `npm` instead.
--
-- >>> :set -XDataKinds
-- >>> import Graphics.Color.Space.RGB
-- >>> npmStandard :: NPM SRGB Float
-- [ [ 0.412400, 0.357600, 0.180500 ]
-- , [ 0.212600, 0.715200, 0.072200 ]
-- , [ 0.019300, 0.119200, 0.950500 ] ]
--
-- @since 0.1.0
npmStandard :: RealFloat a => NPM SRGB a
npmStandard = NPM $ M3x3 (V3 0.4124 0.3576 0.1805)
                         (V3 0.2126 0.7152 0.0722)
                         (V3 0.0193 0.1192 0.9505)


-- | sRGB inverse normalized primary matrix. This is a helper definition, use `inpm` instead.
--
-- >>> :set -XDataKinds
-- >>> import Graphics.Color.Space.RGB
-- >>> inpmStandard :: INPM SRGB Float
-- [ [ 3.240600,-1.537200,-0.498600 ]
-- , [-0.968900, 1.875800, 0.041500 ]
-- , [ 0.055700,-0.204000, 1.057000 ] ]
--
-- @since 0.1.0
inpmStandard :: RealFloat a => INPM SRGB a
inpmStandard = INPM $ M3x3 (V3  3.2406 -1.5372 -0.4986)
                           (V3 -0.9689  1.8758  0.0415)
                           (V3  0.0557 -0.2040  1.0570)


-- | sRGB transfer function "gamma". This is a helper function, therefore `ecctf` should be used
-- instead.
--
-- \[
-- \gamma(u) = \begin{cases}
--     12.92 u & u \leq 0.0031308 \\
--     1.055 u^{1/2.4} - 0.055 & \text{otherwise}
--   \end{cases}
-- \]
--
-- @since 0.1.0
transfer :: (Ord a, Floating a) => a -> a
transfer u
  | u <= 0.0031308 = 12.92 * u
  | otherwise = 1.055 * (u ** (1 / 2.4)) - 0.055
{-# INLINE transfer #-}

-- | sRGB inverse transfer function "gamma". This is a helper function, therefore `dcctf` should
-- be used instead.
--
-- \[
-- \gamma^{-1}(u) = \begin{cases}
--     u / 12.92 & u \leq 0.04045 \\
--     \left(\tfrac{u + 0.055}{1.055}\right)^{2.4} & \text{otherwise}
--   \end{cases}
-- \]
--
-- @since 0.1.0
itransfer :: (Ord a, Floating a) => a -> a
itransfer u
  | u <= 0.04045 = u / 12.92
  | otherwise = ((u + 0.055) / 1.055) ** 2.4
{-# INLINE itransfer #-}
