#!/bin/sh -l

#SBATCH --nodes=4                    ##number of requested nodes (a node is a group of CPUs)
#SBATCH -n 20                        ##number of requested CPUs
#SBATCH --time=08:00:00              ##time requested
#SBATCH --job-name ProjectDenoise    ##name of job
#SBATCH -A microbiome                ##name of the queue you are using. Could be scholar or microbiome if you are on sn$
#########################################################################

echo "Start time"
date +"%d %B %Y %H:%M:%S"

##Step 1, Load Conda environment for Qiime. NOTE: DO THIS BEFORE SUBMITTING JOB

#run:	module load conda
#run:	conda activate qiime2-amplicon-2024.10

##Step 2, Use Manifest file to make demux.qza file 

qiime tools import \
--type 'SampleData[PairedEndSequencesWithQuality]' \
#Change next line with manifest filename
--input-path <manifest.filename> \ 
--input-format PairedEndFastqManifestPhred33V2 \
--output-path demux.qza

echo "End time"
date +"%d %B %Y %H:%M:%S"

#to run: sbatch manifest_pipeline.slurm
