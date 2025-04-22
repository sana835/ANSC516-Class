#!/bin/sh -l

#SBATCH --nodes=1                               ##number of requested nodes (a node is a group of CPUs)
#SBATCH -n 12                                   ##number of requested CPUs
#SBATCH --time=08:00:00                         ##time requested
#SBATCH --job-name Project_Diversity            ##name of job
#SBATCH -A microbiome                           ##name of the queue you are using.

#########################################################################

echo "Start time"
date +"%d %B %Y %H:%M:%S"

#step 1, cd into the proper directory. This directory must already exist

cd /scratch/bell/mohamm69/project/
cd manifest_import/

pwd

#step 2 make sure you are in the qiime conda enviroment when submitting this job

##run:  module load conda
##run:  conda activate qiime2-amplicon-2024.10


echo "initiating qiime2 pipeline"

#Calculate diversity metrics. You will need to designate a --p-sampling-depth. You will want to consult the rarifaction output to help you make a decision.

##NOTE: Make sure there is no core-metrics-results dir in the manifest_import/ dir

qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table table.qza \
  --p-sampling-depth 8000 \
  --m-metadata-file SraRunTable.txt \
  --output-dir core-metrics-results

qiime diversity alpha \
  --i-table table.qza \
  --p-metric chao1 \
  --o-alpha-diversity core-metrics-results/chao1_vector.qza

qiime diversity alpha \
  --i-table table.qza \
  --p-metric simpson \
  --o-alpha-diversity core-metrics-results/simpson_vector.qza

#Statistical testing

#Alpha Diversity Significance 

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
  --m-metadata-file SraRunTable.txt \
  --o-visualization core-metrics-results/faith-pd-group-significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/evenness_vector.qza \
  --m-metadata-file SraRunTable.txt \
  --o-visualization core-metrics-results/evenness-group-significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/shannon_vector.qza \
  --m-metadata-file SraRunTable.txt \
  --o-visualization core-metrics-results/shannon-group-significance.qzv

qiime diversity alpha-group-significance \                                                                                --i-alpha-diversity core-metrics-results/observed_features_vector.qza \
  --i-alpha-diversity core-metrics-results/observed_features_vector.qza \ 
  --m-metadata-file SraRunTable.txt \
  --o-visualization core-metrics-results/observed_features-group-significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/chao1_vector.qza \
  --m-metadata-file SraRunTable.txt \
  --o-visualization core-metrics-results/chao1-group-significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/simpson_vector.qza \
  --m-metadata-file SraRunTable.txt \
  --o-visualization core-metrics-results/simpson-group-significance.qzv

#Beta Diversity Significance

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file SraRunTable.txt \
  --m-metadata-column Host \
  --o-visualization core-metrics-results/unweighted-unifrac-Host-significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/bray_curtis_distance_matrix.qza \
  --m-metadata-file SraRunTable.txt \
  --m-metadata-column Host \
  --o-visualization core-metrics-results/bray_curtis-Host-significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file SraRunTable.txt \
  --m-metadata-column Host \
  --p-method 'permdisp' \
  --o-visualization core-metrics-results/unweighted-unifrac-Host-permdisp.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/bray_curtis_distance_matrix.qza \
  --m-metadata-file SraRunTable.txt \
  --m-metadata-column Host \
  --p-method 'permdisp' \
  --o-visualization core-metrics-results/bray_curtis_distance_matrix-Host-permdisp.qzv \
  --p-pairwise

#Create Ordinations

qiime emperor plot \
  --i-pcoa core-metrics-results/unweighted_unifrac_pcoa_results.qza \
  --m-metadata-file SraRunTable.txt \
  --o-visualization core-metrics-results/unweighted-unifrac-emperor.qzv


qiime emperor plot \
  --i-pcoa core-metrics-results/bray_curtis_pcoa_results.qza \
  --m-metadata-file SraRunTable.txt \
  --o-visualization core-metrics-results/bray-curtis-emperor.qzv

echo "End Time"
date +"%d %B %Y %H:%M:%S"

#to run:	sbatch qiime_pipeline2.slurm
