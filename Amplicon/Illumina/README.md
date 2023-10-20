
# Illumina amplicon analysis workflow

The WDL version of [GeneLab bioinformatics processing pipeline for Illumina amplicon sequencing data](https://github.com/nasa/GeneLab_Data_Processing/tree/master/Amplicon/Illumina)

## Running Workflow in Cromwell

Description of the files:
 - `AmpIllumina.wdl` file: the WDL file for workflow definition
 - `test_input.json` file: the example input for the WDL workflow
 - `config.json` file: the conf file for Snakemake of the Illumina amplicon analysis workflow.

## The Docker image and Dockerfile can be found here

[bioedge/ampillumina:1.0.1](https://hub.docker.com/r/bioedge/ampillumina)

## Input files

`test_input.json`

```json
{
    "AmpIllumina.config_json": "/path/to/Illumina/config.json"
}
```

`config.json`

```json
{
    "data_type": "PE",
    "sample_info_file": "/path/to/unique-sample-IDs.txt",
    "raw_reads_dir": "/path/to/Raw_Sequence_Data/",
    "raw_R1_suffix": "_R1_raw.fastq.gz",
    "raw_R2_suffix": "_R2_raw.fastq.gz",
    "trim_primers": "TRUE",
    "F_primer": "^GTGCCAGCMGCCGCGGTAA",
    "R_primer": "^GGACTACHVGGGTWTCTAA",
    "primers_linked": "TRUE",
    "F_linked_primer": "^GTGCCAGCMGCCGCGGTAA...TTAGAWACCCBDGTAGTCC",
    "R_linked_primer": "^GGACTACHVGGGTWTCTAA...TTACCGCGGCKGCTGGCAC",
    "discard_untrimmed": "TRUE",
    "target_region": "16S",
    "left_trunc": 0,
    "right_trunc": 0,
    "left_maxEE": 1,
    "right_maxEE": 1,
    "min_cutadapt_len": 130,
    "primer_trimmed_R1_suffix": "_R1_trimmed.fastq.gz",
    "primer_trimmed_R2_suffix": "_R2_trimmed.fastq.gz",
    "filtered_R1_suffix": "_R1_filtered.fastq.gz",
    "filtered_R2_suffix": "_R2_filtered.fastq.gz",
    "output_prefix": "projct_name-",
    "fastqc_out_dir": "/path/to/FastQC_Outputs/",
    "trimmed_reads_dir": "/path/to/Trimmed_Sequence_Data/",
    "filtered_reads_dir": "/path/to/Filtered_Sequence_Data/",
    "final_outputs_dir": "/path/to/Final_Outputs/"
}
```

## Output files
The output will have four directories and one zip file of all output.

```
|--output_prefix_outdirs.zip
|--FastQC_Outputs/
│   ├── filtered_multiqc_report.zip
│   └── raw_multiqc_report.zip
|--Trimmed_Sequence_Data/
│   ├── xxx_trimmed.fastq.gz
│   ├── etc.
│   ├── cutadapt.log
│   └── trimmed-read-counts.tsv
|--Filtered_Sequence_Data/
│   ├── xxx_filtered.fastq.gz
│   ├── etc.
│   └── filtered-read-counts.tsv
|--Final_Outputs/
│   ├── ASVs.fasta
│   ├── counts.tsv
│   ├── counts.json
│   ├── read-count-tracking.tsv
│   ├── read-count-tracking.json
│   ├── taxonomy-and-counts.biom.zip
│   ├── taxonomy-and-counts.tsv
│   ├── taxonomy-and-counts.json
│   ├── taxonomy.json
│   └── taxonomy.tsv

```

## Notes
* make sure the raw reads with suffix _R1_raw.fastq.gz or _R2_raw.fastq.gz as defined in config.json
* adjust minimum length threshold for cutadapt in config.json. If too stringent, there will be no reads for downstream analysis.