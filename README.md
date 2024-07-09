# basecall_quality
Make nice histograms of basecalling quality for one or more samples

The shell script can be used directly with the output of dorado summary. The rscript expects a two column file with header "sequence_length_template        mean_qscore_template"

Using the rscript directly is more reliable and flexible with naming. Titles provided to the shell script must not contain spaces.
