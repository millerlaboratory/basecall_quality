#!/bin/bash

WDIR=$(pwd)

TITLE="Mean Quality"
NAMES=""
SUBSAMPLE=1000000
OUTPUT="$WDIR/plot.png"

usage="""bash makePlot.sh [-h] [-o outputName.png] [-s n] [-t title] [-n names-of-comparison-files] [-w working/directory/path] file1.tsv file2.tsv ...
where:
  -h  show this help
  -o  filepath for plot output. Can be png, pdf, svg if you have svgLite installed
  -s  reads to subsample (default is 1,000,000)
  -t  title for plot (default is Mean Quality)
  -w  working directory for temporary files (default is this directory)

Supply the paths to dorado summary files as unnamed arguments.
If dorado summary can not be used, use R script directly and supply a two column, tab separated file with named columns 'sequence_length_tempalte' and 'mean_qscore_template'
"""

while getopts "o:s:t:n:w:h:" opt; do
  case "$opt" in
    o) OUTPUT=$OPTARG ;;
    s) SUBSAMPLE=$OPTARG ;;
    t) TITLE=$OPTARG ;;
    n) NAMES=$OPTARG ;;
    w) WDIR=$OPTARG ;;
    h) echo "$usage"
        exit ;;
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
