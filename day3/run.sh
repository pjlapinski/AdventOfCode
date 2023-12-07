#!/bin/sh

OUTPUT=./output

# clang++ day3.cpp -o $OUTPUT
odin build . -output:$OUTPUT 

echo "EXAMPLE"
$OUTPUT example.txt
echo "INPUT"
$OUTPUT input.txt
