module Main where
import qualified Network.AWS.Prelude as AwsPrelude
import Turtle
import Aws
import Utils
import Types

description = "CLI tool for querying Spot prices on amazon."

spotPricesArgs = (,,) <$> (many (optRead "region" 'r'  "Region for spot price lookup."))
            <*> (many (optText "zone" 'z' "Availability zone for spot price lookup."))
            <*> (many (optRead "instancetype" 't' "Instance type for spot price lookup."))

main :: IO ()
main = do
  (rs, zs, ts) <- options description spotPricesArgs
  ps <- getSpotPrices (fmap readRegion rs) zs (fmap readInstanceType ts)
  printSpotPrices ps
