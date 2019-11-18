{-# LANGUAGE BangPatterns #-}
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
-- Module      : Graphics.ColorSpace.RGB.SRGB
-- Copyright   : (c) Alexey Kuleshevich 2018-2019
-- License     : BSD3
-- Maintainer  : Alexey Kuleshevich <lehins@yandex.ru>
-- Stability   : experimental
-- Portability : non-portable
--
module Graphics.ColorSpace.RGB.SRGB
  ( SRGB
  , pattern PixelRGB8
  , pattern PixelRGB16
  , pattern PixelRGB32
  , pattern PixelRGB64
  , pattern PixelRGBF
  , pattern PixelRGBD
  , ToRGB(..)
  , Rec601(..)
  , primaries
  , npmStandard
  , inpmStandard
  , transfer
  , itransfer
  , module Graphics.ColorSpace.Internal
  , module Graphics.ColorSpace.RGB.Internal
  ) where

import Foreign.Storable
import Graphics.ColorModel.Alpha
import Graphics.ColorModel.Internal
import qualified Graphics.ColorModel.RGB as CM
import Graphics.ColorSpace.Algebra
import Graphics.ColorSpace.Internal
import Graphics.ColorSpace.RGB.Internal
import Graphics.ColorSpace.RGB.Luma
import Graphics.ColorSpace.RGB.ITU.Rec709 (Rec601(..), primaries)


-- | The most common @sRGB@ color space with the default `D65` illuminant
data SRGB

newtype instance Pixel SRGB e = SRGB (Pixel CM.RGB e)

-- | Constructor for a pixel in @sRGB@ color space with 8-bits per channel
pattern PixelRGB8 :: Word8 -> Word8 -> Word8 -> Pixel SRGB Word8
pattern PixelRGB8 r g b = SRGB (CM.PixelRGB r g b)
{-# COMPLETE PixelRGB8 #-}

-- | Constructor for a pixel in @sRGB@ color space with 16-bits per channel
pattern PixelRGB16 :: Word16 -> Word16 -> Word16 -> Pixel SRGB Word16
pattern PixelRGB16 r g b = SRGB (CM.PixelRGB r g b)
{-# COMPLETE PixelRGB16 #-}

-- | Constructor for a pixel in @sRGB@ color space with 32-bits per channel
pattern PixelRGB32 :: Word32 -> Word32 -> Word32 -> Pixel SRGB Word32
pattern PixelRGB32 r g b = SRGB (CM.PixelRGB r g b)
{-# COMPLETE PixelRGB32 #-}

-- | Constructor for a pixel in @sRGB@ color space with 64-bits per channel
pattern PixelRGB64 :: Word64 -> Word64 -> Word64 -> Pixel SRGB Word64
pattern PixelRGB64 r g b = SRGB (CM.PixelRGB r g b)
{-# COMPLETE PixelRGB64 #-}

-- | Constructor for a pixel in @sRGB@ color space with 32-bit floating point value per channel
pattern PixelRGBF :: Float -> Float -> Float -> Pixel SRGB Float
pattern PixelRGBF r g b = SRGB (CM.PixelRGB r g b)
{-# COMPLETE PixelRGBF #-}

-- | Constructor for a pixel in @sRGB@ color space with 32-bit floating point value per channel
pattern PixelRGBD :: Double -> Double -> Double -> Pixel SRGB Double
pattern PixelRGBD r g b = SRGB (CM.PixelRGB r g b)
{-# COMPLETE PixelRGBD #-}


-- | s`RGB` color space
deriving instance Eq e => Eq (Pixel SRGB e)
-- | s`RGB` color space
deriving instance Ord e => Ord (Pixel SRGB e)
-- | s`RGB` color space
deriving instance Functor (Pixel SRGB)
-- | s`RGB` color space
deriving instance Applicative (Pixel SRGB)
-- | s`RGB` color space
deriving instance Foldable (Pixel SRGB)
-- | s`RGB` color space
deriving instance Traversable (Pixel SRGB)
-- | s`RGB` color space
deriving instance Storable e => Storable (Pixel SRGB e)

-- | s`RGB` color space
instance Elevator e => Show (Pixel SRGB e) where
  showsPrec _ = showsColorModel

-- | s`RGB` color space
instance Elevator e => ColorModel SRGB e where
  type Components SRGB e = (e, e, e)
  toComponents = toComponents . unPixelRGB
  {-# INLINE toComponents #-}
  fromComponents = mkPixelRGB . fromComponents
  {-# INLINE fromComponents #-}
  showsColorModelName = showsColorModelName . unPixelRGB

-- | s`RGB` color space
instance Elevator e => ColorSpace SRGB e where
  type BaseColorSpace SRGB = SRGB
  toBaseColorSpace = id
  {-# INLINE toBaseColorSpace #-}
  fromBaseColorSpace = id
  {-# INLINE fromBaseColorSpace #-}
  toPixelXYZ = rgb2xyz . fmap toRealFloat
  {-# INLINE toPixelXYZ #-}
  fromPixelXYZ = fmap fromRealFloat . xyz2rgb
  {-# INLINE fromPixelXYZ #-}
  showsColorSpaceName _ = ("sRGB Standard" ++)

-- | s`RGB` color space
instance RedGreenBlue SRGB 'D65 where
  chromaticity = primaries
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
-- >>> import Graphics.ColorSpace.RGB
-- >>> npmStandard :: NPM SRGB 'D65 Float
-- [ [ 0.412400, 0.357600, 0.180500 ]
-- , [ 0.212600, 0.715200, 0.072200 ]
-- , [ 0.019300, 0.119200, 0.950500 ] ]
--
-- @since 0.1.0
npmStandard :: RealFloat a => NPM SRGB 'D65 a
npmStandard = NPM $ M3x3 (V3 0.4124 0.3576 0.1805)
                         (V3 0.2126 0.7152 0.0722)
                         (V3 0.0193 0.1192 0.9505)


-- | sRGB inverse normalized primary matrix. This is a helper definition, use `inpm` instead.
--
-- >>> :set -XDataKinds
-- >>> import Graphics.ColorSpace.RGB
-- >>> inpmStandard :: INPM SRGB 'D65 Float
-- [ [ 3.240600,-1.537200,-0.498600 ]
-- , [-0.968900, 1.875800, 0.041500 ]
-- , [ 0.055700,-0.204000, 1.057000 ] ]
--
-- @since 0.1.0
inpmStandard :: RealFloat a => INPM SRGB 'D65 a
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

-- | Conversion to s`RGB` color space.
class ToRGB cs where

  -- | Convert to an s`RGB` pixel.
  toPixelRGB :: (Elevator e, Elevator a, RealFloat a) => Pixel cs e -> Pixel SRGB a
  -- | Convert to an s`RGB` pixel with alpha channel
  toPixelRGBA :: (Elevator e, Elevator a, RealFloat a) => Pixel cs e -> Pixel (Alpha SRGB) a
  toPixelRGBA = (`addAlpha` 1) . toPixelRGB
  {-# INLINE toPixelRGBA #-}

instance ToRGB SRGB where
  toPixelRGB = fmap toRealFloat
  {-# INLINE toPixelRGB #-}

-- instance ToRGB YCbCr where
--   toPixelRGB = ycbcr2rgb . fmap toRealFloat
--   {-# INLINE toPixelRGB #-}


-- instance ToYCbCr SRGB where
--   toPixelYCbCr = rgb2ycbcr . fmap toRealFloat
--   {-# INLINE toPixelYCbCr #-}

-- -- | Source: ITU-T Rec. T.871
-- ycbcr2rgb :: (Ord e, Floating e) => Pixel YCbCr e -> Pixel SRGB e
-- ycbcr2rgb (PixelYCbCr y cb cr) = PixelRGB r g b
--   where
--     !cb05 = cb - 0.5
--     !cr05 = cr - 0.5
--     !r = clamp01 (y                  +   1.402 * cr05)
--     !g = clamp01 (y - 0.34414 * cb05 - 0.71414 * cr05)
--     !b = clamp01 (y + 1.772   * cb05)
-- {-# INLINE ycbcr2rgb #-}

-- -- | Source: ITU-T Rec. T.871
-- rgb2ycbcr :: Floating e => Pixel SRGB e -> Pixel YCbCr e
-- rgb2ycbcr (PixelRGB r g b) = PixelYCbCr y cb cr
--   where
--     !y  =          0.299 * r +    0.587 * g +    0.114 * b
--     !cb = 0.5 - 0.168736 * r - 0.331264 * g +      0.5 * b
--     !cr = 0.5 +      0.5 * r - 0.418688 * g - 0.081312 * b
-- {-# INLINE rgb2ycbcr #-}

