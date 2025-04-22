#!/bin/sh -l

#SBATCH --nodes=4                    ##number of requested nodes (a node is a group of CPUs)
#SBATCH -n 20		             ##number of requested CPUs
#SBATCH --time=08:00:00              ##time requested
#SBATCH --job-name Project_dada2     ##name of job
#SBATCH -A microbiome                ##name of the queue you are using. Could be scholar or microbiome if you are on snyder

#########################################################################

#Make sure you have run the manifest_pipeline.slurm code first to create the demux.qza file

echo "Start time"
date +"%d %B %Y %H:%M:%S"

##Step 1, cd into the proper directory. This directory must already exist

cd /scratch/bell/mohamm69/project/
cd manifest_import/

pwd

##Step 2, Load Conda environement in terminal prior to submitting job

#run:	module load conda
#run:	conda activate qiime2-amplicon-2024.10

##Step 3, Run the code you want

#De-noise. Error Corrections.

echo "Running dada2 paired end code"

qiime dada2 denoise-paired \
  --i-demultiplexed-seqs demux.qza \
  --p-trim-left-f 5 \
  --p-trim-left-r 5 \
  --p-trunc-len-f 250 \
  --p-trunc-len-r 250 \
  --o-table table.qza \
  --o-representative-sequences rep-seqs.qza \
  --o-denoising-stats denoising-stats.qza

#Convert .qza to .qzv format

qiime metadata tabulate \
  --m-input-file denoising-stats.qza \
  --o-visualization denoising-stats.qzv

qiime feature-table summarize \
  --i-table table.qza \
  --o-visualization table.qzv \
  --m-sample-metadata-file manifest_file.txt

qiime feature-table tabulate-seqs \
  --i-data rep-seqs.qza \
  --o-visualization rep-seqs.qzv

#Phylogenetic Tree creation for Diversity and Rarefaction Analysis

qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seqs.qza \
  --o-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza

#Alpha Rarefaction Curve, to calculate subsampling depth

qiime diversity alpha-rarefaction \
  --i-table table.qza \
  --i-phylogeny rooted-tree.qza \
  --p-max-depth 10000 \
  --m-metadata SraRunTable.txt \
  --o-visualization alpha-rarefaction.qzv

echo "End time"
date +"%d %B %Y %H:%M:%S"

#to run: sbatch qiime_pipeline.slurm
