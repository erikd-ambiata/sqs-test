{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

import Control.Exception
import Control.Lens

import Mismi.Kernel.Data
import Mismi.SQS
import Mismi.SQS.Amazonka

import P

import System.IO

import X.Control.Monad.Trans.Either


main :: IO ()
main = do
  let queue =
        Queue (QueueName "erikd-was-here") SydneyRegion
  let region =
        fromMismiRegion $ queueRegion queue
  res <- runEitherT . runAWSWithRegion region $ onQueue queue (Just 8400) wibble
  print res


wibble :: QueueUrl -> AWS ()
wibble q = do
  let msg =
        "Here is a messgae"
  void $ writeMessage q msg Nothing
  ms <- readMessages q (Just 1) Nothing
  assert ([Just msg] == fmap (^. mBody) ms) $ pure ()
