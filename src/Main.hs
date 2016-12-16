module Main where
import qualified Network.AWS.Prelude as AwsPrelude
import Turtle
import Aws
import Utils
import Types
import Data.Traversable as Traversable
description = "CLI tool for querying amazon EC2 Spot prices."

spotPricesArgs = (,,) <$> (many (optText "region" 'r'  "Region for spot price lookup. etc: us-east-1 , NorthVirginia"))
            <*> (many (optText "zone" 'z' "Availability zone for spot price lookup. etc: us-east-1e"))
            <*> (many (optText "instancetype" 't' "Instance type for spot price lookup."))

main :: IO ()
main = do
  (rrs, rzs, rts) <- options description spotPricesArgs
  let rs = fmap (fmap readRegion) $ Traversable.traverse eitherRead rrs
  let ts = fmap (fmap readInstanceType) $ Traversable.traverse eitherRead rts
  ps <- either die id (getSpotPrices <$> rs <*> pure rzs <*> ts )
  printSpotPrices ps
