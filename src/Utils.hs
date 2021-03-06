module Utils where
import qualified Turtle as Turtle
-- import qualified Data.Optional as Optional
import qualified Network.AWS.Prelude as AwsPrelude
import qualified Text.PrettyPrint.Boxes as Boxes
import Aws
import qualified Data.List as List
import qualified Data.Text as Text

-- source:
-- http://www.tedreed.info/programming/2012/06/02/how-to-use-textprettyprintboxes/
print_table :: [[String]] -> IO ()
print_table rows = Boxes.printBox $ Boxes.hsep 2 Boxes.left (map (Boxes.vcat Boxes.left . map Boxes.text) (List.transpose rows))


printSpotPrices :: [HawsSpotPrice] -> IO ()
printSpotPrices ss = print_table $ headers : fmap toList ss
  where
    headers = ["Availability_Zone", "Price", "Instance_Type"]
    toList :: HawsSpotPrice -> [String]
    toList HawsSpotPrice{zone=z,
                         priceStr=p,
                         instanceType=t} = fmap Text.unpack [z, p, AwsPrelude.toText t]

printSpotPricesScript :: [HawsSpotPrice] -> IO ()
printSpotPricesScript ss = print_table $ [head $ fmap toList ss]
  where
    toList :: HawsSpotPrice -> [String]
    toList HawsSpotPrice{zone=z,
                         priceStr=p,
                         instanceType=t} = fmap Text.unpack [z, p, AwsPrelude.toText t]

printSpotPricesScriptAll :: [HawsSpotPrice] -> IO ()
printSpotPricesScriptAll ss = print_table $ fmap toList ss
  where
    toList :: HawsSpotPrice -> [String]
    toList HawsSpotPrice{zone=z,
                         priceStr=p,
                         instanceType=t} = fmap Text.unpack [z, p, AwsPrelude.toText t]

eitherRead :: Read a => Text.Text -> Either Text.Text a
eitherRead t = case reads (Text.unpack t) of
                  [(a, "")] -> Right a
                  _ -> Left (Text.concat ["Cannot parse ", t])
