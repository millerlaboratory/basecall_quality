# basecall_quality
Make nice histograms of basecalling quality for one or more samples

![a trivial example](https://github.com/[millerlaboratory]/[basecall_quality]/blob/main/test_for_repo.png?raw=true)

The shell script can be used directly with the output of dorado summary. The rscript expects a two column file with header "sequence_length_template        mean_qscore_template"

Using the rscript directly is more reliable and flexible with naming. Titles provided to the shell script must not contain spaces.

Requirements:
R >= 4.2.2
R packages:
  - plyr
  - dplyr
  - ggplot2
  - stringr
  - RColorBrewer
  - optparse
