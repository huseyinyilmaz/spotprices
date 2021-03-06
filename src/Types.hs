module Types where

import qualified Network.AWS.Prelude as AwsPrelude

import qualified Text.ParserCombinators.ReadP as P
import Text.ParserCombinators.ReadPrec
import qualified Text.Read.Lex as L
import Text.Read
import qualified Data.Text as Text
import Turtle
import qualified Data.Char as Char
import Debug.Trace as Trace
import qualified Network.AWS.EC2.Types as AwsTypes

newtype RegionReader = RegionReader{readRegion :: AwsPrelude.Region} deriving (Show)
-- source:
-- http://stackoverflow.com/a/38817257/350127
instance Read RegionReader where
  readsPrec _ str =
         case AwsPrelude.fromText (Text.pack str) of
           Right r  -> [(RegionReader r, "")]
           Left e -> case reads str of
                       [(r, "")] -> [(RegionReader r, "")]
                       e -> []


newtype InstanceTypeReader = InstanceTypeReader{readInstanceType :: AwsTypes.InstanceType} deriving (Show)
instance Read InstanceTypeReader where
  readsPrec _ str =
         case AwsPrelude.fromText (Text.pack str) of
           Right t  -> [(InstanceTypeReader t, "")]
           Left e -> case reads str of
                       [(t, "")] -> [(InstanceTypeReader t, "")]
                       e -> []


data Consumer = Script
              | Human
              | ScriptAll
  deriving (Show)

instance Read Consumer where
  readsPrec _ str =
         case fmap Char.toLower str of
           "script"    -> [(Script, "")]
           "human"     -> [(Human, "")]
           "scriptall" -> [(ScriptAll, "")]
           _           -> []
