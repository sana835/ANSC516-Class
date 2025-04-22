#!/bin/sh -l

#SBATCH --nodes=4                    ##number of requested nodes (a node is a group of CPUs)
#SBATCH -n 20                        ##number of requested CPUs
#SBATCH --time=08:00:00              ##time requested
#SBATCH --job-name Project_taxonomy  ##name of job
#SBATCH -A microbiome                ##name of the queue you are using. Could be scholar or microbiome if you are on snyder

#########################################################################

echo "Start time"
date +"%d %B %Y %H:%M:%S"

##Step 1, cd into the proper directory. This directory must already exist

cd /scratch/bell/mohamm69/project/
cd manifest_import/

pwd

##Step 2, Load Conda environement in terminal prior to submitting job

#run:   module load conda
#run:   conda activate qiime2-amplicon-2024.10

##Step 3, Run the code you want

echo "Taxonomic Analysis"

wget \
  -O "gg-13-8-99-515-806-nb-classifier.qza" \
  "https://data.qiime2.org/2023.9/common/gg-13-8-99-515-806-nb-classifier.qza"

qiime feature-classifier classify-sklearn \
  --i-classifier gg-13-8-99-515-806-nb-classifier.qza \
  --i-reads rep-seqs.qza \
  --o-classification taxonomy.qza

qiime metadata tabulate \
  --m-input-file taxonomy.qza \
  --o-visualization taxonomy.qzv

echo "Taxanomic Barplot"

qiime taxa barplot \
  --i-table table.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file SraRunTable.txt \
  --o-visualization taxa-bar-plots.qzv

#ANCOM with Endosphere samples

echo "Endosphere ANCOM"

qiime feature-table filter-samples \
  --i-table table.qza \
  --m-metadata-file SraRunTable.txt \
  --p-where "[isolation_source]='root endosphere of greenhouse grown plants in natural soil mixed with potting mix'" \
  --o-filtered-table endosphere-table.qza

qiime composition add-pseudocount \
  --i-table endosphere-table.qza \
  --o-composition-table comp-endo-table.qza

qiime composition ancom \
  --i-table comp-endo-table.qza \
  --m-metadata-file SraRunTable.txt \
  --m-metadata-column Host \
  --o-visualization ancom-Host.qzv

#Differential Abundance at a Taxonomic Level

qiime taxa collapse \
  --i-table endosphere-table.qza \
  --i-taxonomy taxonomy.qza \
  --p-level 6 \
  --o-collapsed-table endo-table-l6.qza

qiime composition add-pseudocount \
  --i-table endo-table-l6.qza \
  --o-composition-table comp-endo-table-l6.qza

qiime composition ancom \
  --i-table comp-eno-table-l6.qza \
  --m-metadata-file SraRunTable.txt \
  --m-metadata-column Host \
  --o-visualization l6-ancom-Host.qzv

echo "End time"
date +"%d %B %Y %H:%M:%S"

#to run: sbatch qiime_pipeline3.slurm
