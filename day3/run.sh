#!/bin/sh

OUTPUT=./output

clang++ day3.cpp -o $OUTPUT
echo "EXAMPLE"
$OUTPUT example.txt
echo "INPUT"
$OUTPUT input.txt

