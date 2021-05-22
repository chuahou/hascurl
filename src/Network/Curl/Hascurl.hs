-- SPDX-License-Identifier: MIT
-- Copyright (c) 2021 Chua Hou

-----------------------------------------------------------------------------
-- |
-- Module      : Network.Curl.Hascurl
-- Copyright   : Chua Hou 2021
-- License     : MIT
--
-- Maintainer  : Chua Hou <human+github@chuahou.dev>
-- Stability   : experimental
-- Portability : non-portable
--
-- Simple Haskell bindings to a small subset of libcurl. Most packages available
-- now either seem actively maintained or provide a more feature-rich network
-- request experience, so this package is meant for personal use for when I only
-- need the very basics.
-----------------------------------------------------------------------------

{-# LANGUAGE ForeignFunctionInterface #-}

module Network.Curl.Hascurl ( get
                            , post
                            ) where

import           Data.List        (intercalate)
import           Foreign.C.String (CString, newCString, peekCString)
import           Foreign.Marshal  (free, maybePeek)

foreign import ccall "get" c_get :: CString -> IO CString
foreign import ccall "post" c_post :: CString -> CString -> IO CString

-- | Perform a GET request to the url @url@. Returns @Just cs@ if the request is
-- successful and the response is @cs@, and returns @Nothing@ otherwise.
get :: String -> IO (Maybe String)
get url = do
    c_url   <- newCString url -- Marshal URL into C string.
    out_ptr <- c_get c_url    -- Perform request.
    free c_url
    maybePeek (peekCString <* free) out_ptr
                              -- Get Just string from pointer, Nothing if
                              -- pointer is NULL, then free it.

-- | Perform a POST request to the url @url@, with fields given in @fields@. Use
-- @Nothing@ when wanting to POST the empty argument. Returns @Just cs@ if the
-- request is successful and the response is @cs@, and returns @Nothing@
-- otherwise.
post :: String -> [(String, Maybe String)] -> IO (Maybe String)
post url fields = do
    c_url    <- newCString url -- Marshal URL into C string.
    c_fields <- newCString $ intercalate "&" $ map (\(a, b) -> case b of
        Just b' -> a <> "=" <> b'
        Nothing -> a) fields
    out_ptr  <- c_post c_url c_fields
    free c_url
    free c_fields
    maybePeek (peekCString <* free) out_ptr
                              -- Get Just string from pointer, Nothing if
                              -- pointer is NULL, then free it.
