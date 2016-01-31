#!/bin/bash

fName="/ssd/`date +%y-%m-%d_%H%M%S`.ts"

cat - | tee $fName > /dev/null
