module Types where

import qualified Network.AWS.Prelude as AwsPrelude

import qualified Text.ParserCombinators.ReadP as P
import Text.ParserCombinators.ReadPrec
import qualified Text.Read.Lex as L
import Text.Read
import qualified Data.Text as Text

-- import Text.ParserCombinators.ReadP
--   ( ReadS
--   , readP_to_S
--   )
import Debug.Trace as Trace

newtype RegionReader = RegionReader{readRegion :: AwsPrelude.Region} deriving (Show)

instance Read RegionReader where
  readPrec =
    parens
    ( do L.Ident s <- lexP
         --
         -- $ stack exec spotprices -- -r us-east-1
         -- Trace output:
         -- Left "Failed reading: Failure parsing Region from us"
         case Trace.traceShowId$AwsPrelude.fromText (Text.pack s) of
           Right r  -> return $ RegionReader r
           Left e -> return $ RegionReader (read s)
    )

  readListPrec = readListPrecDefault
  readList     = readListDefault
