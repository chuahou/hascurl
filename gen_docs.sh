#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou
#
# Generate Haddock docs and copy to docs/ folder for GitHub pages.

cd $(dirname $(realpath $0))
cabal haddock --haddock-hyperlink-source
rm docs/ -rf
cp dist-newstyle/build/x86_64-linux/ghc-*/hascurl-*/doc/html/hascurl -r docs
