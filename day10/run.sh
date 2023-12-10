#!/bin/sh

OUTPUT=./output.exe

odin build . -out:$OUTPUT 

echo "EXAMPLE"
$OUTPUT example.txt
echo "INPUT"
$OUTPUT input.txt
