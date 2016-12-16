module Main where
import qualified Network.AWS.Prelude as AwsPrelude
import Turtle
import Aws
import Utils
import Types
import Data.Traversable as Traversable
import Data.Text as Text
description = "CLI tool for querying amazon EC2 Spot prices."

spotPricesArgs = (,,,) <$> (many (optText "region" 'r'  "Region for spot price lookup. etc: us-east-1 , NorthVirginia"))
            <*> (many (optText "zone" 'z' "Availability zone for spot price lookup. etc: us-east-1e"))
            <*> (many (optText "instancetype" 't' "Instance type for spot price lookup."))
            <*> (many (optText "consumer" 'c' "Consumer of call (values: script, human, scriptall)"))
main :: IO ()
main = do
  (rrs, rzs, rts, rcs) <- options description spotPricesArgs
  let rs = fmap (fmap readRegion) $ Traversable.traverse eitherRead rrs
  let ts = fmap (fmap readInstanceType) $ Traversable.traverse eitherRead rts
  let cs = Traversable.traverse eitherRead rcs
  ps <- either die id (getSpotPrices <$> rs <*> pure rzs <*> ts )
  case cs of
    Left _ -> die $ Text.pack ("Cannot parse consumer value: " <> show (rcs) <> " value must be \"script\" , \"human\" \"scriptall\"")
    Right (Script: _) -> printSpotPricesScript ps
    Right (ScriptAll: _) -> printSpotPricesScriptAll ps
    _ -> printSpotPrices ps
