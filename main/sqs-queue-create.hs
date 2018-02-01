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
  let queueName =
        QueueName "erikd-was-here"
  let region =
        fromMismiRegion SydneyRegion

  res <- runEitherT . runAWSWithRegion region $
            mapM (createQueue queueName) $ fmap Just [10, 20 .. 100]
  case res of
    Left e -> print e
    Right xs -> mapM_ (putStrLn . show) xs


