#!/bin/sh
#
# Update submodules

git submodule sync --recursive || git submodule sync

git submodule update --init --recursive
