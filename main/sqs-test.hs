{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

import Control.Exception
import Control.Lens

import Mismi.Kernel.Data
import Mismi.SQS
import Mismi.SQS.Amazonka (mBody)

import P

import System.IO

import X.Control.Monad.Trans.Either


main :: IO ()
main = do
  let queue =
        Queue (QueueName "erikd-was-here") SydneyRegion
  let region =
        fromMismiRegion $ queueRegion queue
  res <- runEitherT . runAWSWithRegion region $ do
            (<>) <$> onQueue queue (Just 8400) (run "zero")
                 <*> onQueue queue (Just 8401) (run "one")
  print res


run :: Text -> QueueUrl -> AWS [Text]
run msg q = do
  void $ writeMessage q msg Nothing
  ms <- readMessages q (Just 1) Nothing
  assert ([msg] == mapMaybe (^. mBody) ms) $ pure ()
  pure $ mapMaybe (^. mBody) ms
