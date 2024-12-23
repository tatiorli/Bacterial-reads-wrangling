#!/bin/bash
# This script processes a single sample by running the entire pipeline sequentially for that sample.

# Load required modules
module load SAMtools/1.21-GCC-13.2.0
module load FastQC/0.12.1-Java-11

# Define directories (use absolute paths)
INPUT_DIR="/home/labs/straussman/tatianas/rna-seq/start_again_2024/Mapped_to_pangenome/mapping_to_pan_1_again"
PANGENOME_GENOME_DIR="/home/labs/straussman/tatianas/human_pangenomes/testing_with_one_pangenome/pangenome_1"

# Define GTF files
PANGENOME_GTF="$PANGENOME_GENOME_DIR/Homo_sapiens-GCA_018471515.1-2022_08-genes.gtf"

# Sample name is passed as the first argument
sample=$1

# Align unmapped reads with STAR against one Human Pangenome genome
echo "Aligning unmapped reads of $sample using STAR with one Human Pangenome..."
module load STAR/2.7.11b-GCC-13.2.0

# Submit the job and capture the job ID
JOB_ID=$(bsub -q short -J "star_pang1again_${sample}" -R "rusage[mem=64000]" -e "${sample}_STAR_pang1again.error" -o "${sample}_STAR_pang1again.out" -N STAR \
    --genomeDir "$PANGENOME_GENOME_DIR" \
    --sjdbGTFfile "$PANGENOME_GTF" \
    --runThreadN 24 \
    --readFilesIn "${sample}_STAR_pang5_unmapped_R1.fastq" "${sample}_STAR_pang5_unmapped_R2.fastq" \
    --outFileNamePrefix "${sample}_STAR_pang1again_" \
    --outSAMtype BAM SortedByCoordinate \
    --outFilterMismatchNoverLmax 0.04 \
    --alignEndsType EndToEnd \
    --quantMode GeneCounts \
    --outSAMunmapped Within KeepPairs | awk '{print $2}' | sed 's/<//; s/>//')

# Wait for the specific STAR alignment job for pang to complete
echo "Waiting for STAR pang job $JOB_ID for $sample to complete..."
bwait -w "done($JOB_ID)"

# Step 5: Extract unmapped and mapped reads from pang STAR output
echo "Extracting reads from $sample's pang5 STAR output..."
samtools index "${sample}_STAR_pang1again_Aligned.sortedByCoord.out.bam"
samtools fastq -f 12 -1 "${sample}_STAR_pang1again_unmapped_R1.fastq" -2 "${sample}_STAR_pang1again_unmapped_R2.fastq" "${sample}_STAR_pang1again_Aligned.sortedByCoord.out.bam"
samtools fastq -f 2 -1 "${sample}_STAR_pang1again_mapped_R1.fastq" -2 "${sample}_STAR_pang1again_mapped_R2.fastq" "${sample}_STAR_pang1again_Aligned.sortedByCoord.out.bam"

# Run FastQC on unmapped and mapped reads from pang alignment
fastqc "${sample}_STAR_pang1again_unmapped_R1.fastq" "${sample}_STAR_pang1again_unmapped_R2.fastq"
fastqc "${sample}_STAR_pang1again_mapped_R1.fastq" "${sample}_STAR_pang1again_mapped_R2.fastq"

echo "Pipeline completed for $sample."
