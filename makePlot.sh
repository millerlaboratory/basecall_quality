#!/bin/bash

WDIR=$(pwd)

TITLE="Mean Quality"
NAMES=""
SUBSAMPLE=1000000
OUTPUT="$WDIR/plot.png"

while getopts "o:s:t:n:w:" opt; do
  case "$opt" in
    o) OUTPUT=$OPTARG ;;
    s) SUBSAMPLE=$OPTARG ;;
    t) TITLE=$OPTARG ;;
    n) NAMES=$OPTARG ;;
    w) WDIR=$OPTARG ;;
  esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

SAMPLES=( "$@" )

for SAMPLE in ${SAMPLES[@]}
do
  filename=${SAMPLE##*/}
  cut -f10,11 $filename > $WDIR/${filename%*.tsv}.short.temp.tsv
done

if [ ${#SAMPLES[@]} -gt 1 ]
then
  COMPARISONS=$(echo ${SAMPLES[@]} | tr ' ' '-')
  Rscript qualityGraph.R -o $OUTPUT -n $NAMES -s $SUBSAMPLE -t $TITLE -c $COMPARISONS ${SAMPLES[0]}
else
  Rscript qualityGraph.R -o $OUTPUT -n $NAMES -s $SUBSAMPLE -t $TITLE ${SAMPLES[0]}
fi

rm -rf $WDIR/*.short.temp.tsv
