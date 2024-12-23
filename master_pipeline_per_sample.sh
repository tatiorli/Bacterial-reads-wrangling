#!/bin/bash
# This master script runs the entire pipeline in parallel for each sample by calling a helper script for each sample.
# The sample names are read from a file (samples.txt) and the pipeline runs in parallel for each sample.

# Load required modules
module load SAMtools/1.21-GCC-13.2.0
module load FastQC/0.12.1-Java-11

# Path to samples list (make sure samples.txt exists and contains the list of all sample names)
SAMPLES_LIST="/home/labs/straussman/tatianas/rna-seq/start_again_2024/Mapped_to_pangenome/mapping_to_pan_1_again/samples.txt"

# Loop through each sample name and submit a job for each one
while IFS= read -r sample; do
  # Submit a job for each sample
  bsub -q short -J "pipeline_$sample" -o "${sample}.o" -e "${sample}.e" -R "rusage[mem=64000]" -N sh run_sample_pipeline.sh "$sample"
done < "$SAMPLES_LIST"

echo "Master pipeline completed. All jobs have been submitted."
