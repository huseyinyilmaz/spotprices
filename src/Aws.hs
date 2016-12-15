module Aws where
-- module that gets list of spot prices
import           System.IO
import Control.Monad.IO.Class
import Control.Applicative
import Data.Time.Clock
import qualified Data.List as List
import Control.Lens
import Data.Maybe
import Data.Text
import qualified Data.Map as Map
-- amazon imports
import           Network.AWS.EC2.DescribeSpotPriceHistory
import           Network.AWS.EC2.Types
import           Network.AWS.EC2
import           Network.AWS.Data
import           Network.AWS.Prelude
import           Control.Monad.Trans.AWS

--local imports
-- import Debug.Trace as Trace

data HawsSpotPrice = HawsSpotPrice {
  price :: Float,
  priceStr :: Text,
  zone :: Text,
  region :: Region,
  instanceType :: InstanceType,
  timestamp :: UTCTime
  } deriving (Show, Eq, Ord)

fromAmazonka :: Region -> SpotPrice -> HawsSpotPrice
fromAmazonka r s = HawsSpotPrice {
  price = (read  . unpack . fromJust . (view sSpotPrice)) s,
  priceStr = (fromJust . (view sSpotPrice)) s,
  zone = (fromJust . (view sAvailabilityZone)) s,
  region = r,
  instanceType = fromJust $ view sInstanceType s,
  timestamp = (fromJust . (view sTimestamp)) s
  }

filterLatestPrices :: [HawsSpotPrice] -> [HawsSpotPrice]
filterLatestPrices ps = Map.elems $ List.foldl
          (\ m price@HawsSpotPrice{zone=a, instanceType=t, price=p} ->
             let key = (a, t) in
               if Map.member key m then m else Map.insert key price m)
          Map.empty sorted_list
  where sorted_list = (List.reverse . List.sortOn(timestamp)) ps

getSpotPrices :: [Region] -> [Text] -> [InstanceType] -> IO [HawsSpotPrice]
getSpotPrices rs zs ts= do
    lgr <- newLogger Info stdout
    env <- newEnv Discover <&> set envLogger lgr
    now <- getCurrentTime
    let rs' = if rs == [] then [NorthVirginia] else rs
        ts' = if ts == [] then [R3_XLarge] else ts
        start_time = addUTCTime (-60 * 15) now
        query = describeSpotPriceHistory
          & dsphInstanceTypes       .~ ts'
          & dsphProductDescriptions .~ ["Linux/UNIX (Amazon VPC)"]
          & dsphStartTime           .~ (Just start_time)
          & dsphEndTime             .~ (Just now)

    pss <- sequenceA $  fmap (request env query) rs'
    let ps = mconcat pss

    return $ (List.sort . filterLatestPrices . filterByZone) ps
      where
        request :: Env -> DescribeSpotPriceHistory -> Region -> IO [HawsSpotPrice]
        request env query r = do
          resp <- (runResourceT . runAWST env . (within r). send) query
          return $ processResponse r resp

        processResponse:: Region -> DescribeSpotPriceHistoryResponse -> [HawsSpotPrice]
        processResponse r resp =
          fmap (fromAmazonka r) (resp ^. dsphrsSpotPriceHistory)

        filterByZone :: [HawsSpotPrice] -> [HawsSpotPrice]
        filterByZone ps | zs == [] = ps
                        | True     = List.filter
                                     (\s-> List.elem (zone s) zs)
                                     ps
