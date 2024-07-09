#!/usr/bin/env Rscript --vanilla

suppressWarnings(suppressPackageStartupMessages(library(optparse)))
suppressWarnings(suppressPackageStartupMessages(library(plyr)))
suppressWarnings(suppressPackageStartupMessages(library(dplyr)))
suppressWarnings(suppressPackageStartupMessages(library(ggplot2)))

option_list <- list(make_option(c("-c", "--compare"), action="store", help="Path to additional .tsvs of read lengths and quality to compare with, separated by '-' character", default=""),
                    make_option(c("-o", "--output"), action="store", help="Filepath for plot output", default="plot.png"),
                    make_option(c("-s", "--subsample"), action="store", help="subsampling depth", default=1000000),
                    make_option(c("-t", "--title"), action="store", help="Plot title", default="Mean Quality"),
                    make_option(c("-n", "--names"), action="store", help="Dash separated sample names", default="")
                    )

parser <- OptionParser(usage="%prog [options] input", option_list=option_list, description="\nSupply the path to a tsv with read lengths and quality scores output by dorado summary.\n
Optionally compare to a different .tsv using -c or --compare [filename]\n
Output is saved to plot.png or a filename specified with -o or --ouput\n
Example: ./qualityGraph.R M2082-dorado_parsed.tsv -o M2082-graphic.png    -->     outputs a png named M2082-graphic.png")

arguments <- parse_args(parser, positional_arguments=1)
opt <- arguments$options
inputpath <- arguments$args[1]

theme_set(theme_classic(base_size=12))

print(paste("Reading ", inputpath, sep=""))
df <- read.table(inputpath, header=TRUE, sep="\t")

print(paste(inputpath," has ", nrow(df), "rows: subsampling to ", opt$subsample, " rows", sep=""))

dfsub <- df[sample(nrow(df), opt$subsample, replace=FALSE),]
df1median <- median(dfsub$mean_qscore_template)
df1mean <- mean(dfsub$mean_qscore_template)

if( opt$compare == ""){
    print("making plot")
    ggplot(dfsub, aes(x=mean_qscore_template)) + geom_density(alpha=0.5, fill="cornflowerblue", color="cornflowerblue", kernel="cosine", adjust=1.8) + 
    ggtitle(opt$title) + xlab("Base Q") + ylab("Frequency") + geom_vline(xintercept=df1mean, linetype="dashed", color="cornflowerblue") + 
    geom_vline(xintercept=df1median, linetype="solid", color="cornflowerblue")
} else {
    allpaths <- stringr::str_split(opt$compare, pattern="-")[[1]]
    medians=c(df1median)
    means=c(df1mean)
    if(opt$names != ""){
        allnames=stringr::str_split(opt$names, pattern="-")[[1]]
    } else {
        allnames=c(inputpath, allpaths)
    }
    bdf <- dfsub
    bdf$Filename <- allnames[1]
    counter=2
    for(path in allpaths){
        print(paste("reading ",path,sep=""))
        df2 <- read.table(path, header=TRUE, sep="\t")
        if(nrow(df2) < opt$subsample){
            ssample=nrow(df2)
        } else {
            ssample=opt$subsample
        }
        print(paste(path, " has ", nrow(df2), " rows: subsampling to ", ssample, " rows", sep=""))
        dfsub2 <- df2[sample(nrow(df2), ssample, replace=FALSE),]
        medians=c(medians, median(dfsub2$mean_qscore_template))
        means=c(means, mean(dfsub2$mean_qscore_template))
        dfsub2$Filename <- allnames[counter]
        bdf <- rbind(bdf, dfsub2)
        counter=counter+1
    }
    avgdf <- data.frame(Filename=allnames, Median=medians, Mean=means)
    print("making plot")
    
    ggplot() + geom_density(data=bdf, aes(x=mean_qscore_template, fill=Filename, color=Filename), alpha=0.5, kernel="cosine", adjust=1.8) + 
    geom_vline(data=avgdf, aes(color=Filename, xintercept=Mean), linetype="dashed") + geom_vline(data=avgdf, aes(color=Filename, xintercept=Median), linetype="solid") +
    ggtitle(opt$title) + xlab("Base Q") + ylab("Frequency") + scale_fill_viridis_d(name="Sample") + scale_color_viridis_d(name="Sample") + theme(legend.position="bottom")

}

print(paste("saving plot to ", opt$output, sep=""))
ggsave(opt$output, dpi=300, height=8, width=8, unit="in")

print("Done!")
