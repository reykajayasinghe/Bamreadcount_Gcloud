#!/bin/bash
echo "#" > ./run/gcloudcommand.sh
while read lines;
do
index=$(echo $lines | awk -F " " '{print $1}')
bampath=$(echo $lines | awk -F " " '{print $2}')
filename=$(echo $lines | awk -F " " '{print $4}')

echo "gcloud alpha genomics pipelines run \
  --pipeline-file ${filename} \
  --inputs bamfile=${bampath},baifile=${bampath}.bai,reffile=gs://ding_lab_reference/GRCh37-lite.fa,faifile=gs://ding_lab_reference/GRCh37-lite.fa.fai \
  --outputs outputPath=gs://misplice/bamreadcount/output/ \
  --logging gs://misplice/bamreadcount/logging/ \
  --disk-size datadisk:500" >> ./run/gcloudcommand.sh

done < bamsite_index.txt
