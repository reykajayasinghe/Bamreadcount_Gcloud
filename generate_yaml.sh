#!/bin/bash
while read lines;
do 
index=$(echo $lines | awk -F " " '{print $1}')
bampath=$(echo $lines | awk -F " " '{print $2}')
site=$(echo $lines | awk -F " " '{print $3}')
filename=$(echo $lines | awk -F "\t" '{print $4}')
cat bamreadcount.yaml | sed "s/SITE/${site}/g" > run/bamsite_${index}.yaml
done < bamsite_index.txt
