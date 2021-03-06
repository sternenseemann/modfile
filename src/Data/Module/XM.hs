{-# LANGUAGE RecordWildCards #-}

module Data.Module.XM (
      Module (..)
    , getModule
    , putModule
    ) where

import           Control.Monad
import           Data.Binary
import           Data.Word
import           Data.Binary.Get
import           Data.Binary.Put


import Data.Module.XM.Header
import Data.Module.XM.Pattern
import Data.Module.XM.Instrument

data Module = Module { header      :: Header
                     , orders      :: [Word8]
                     , patterns    :: [Pattern]
                     , instruments :: [Instrument]
                     }
    deriving (Show, Eq)

getModule :: Get Module
getModule = do
    header <- getHeader
    orders <- replicateM (fromIntegral (songLength header)) getWord8
    br <- bytesRead
    skip $ (60 + (fromIntegral (headerSize header))) - (fromIntegral br) 
    patterns <- replicateM (fromIntegral (numPatterns header)) getPattern
    instruments <- replicateM (fromIntegral (numInstruments header)) getInstrument
    return $ Module{..}

putModule :: Module -> Put
putModule Module{..} = do
    putHeader header
    mapM_ putWord8 orders
    mapM_ putPattern patterns
    mapM_ putInstrument instruments

