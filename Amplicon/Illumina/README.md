
# Illumina amplicon analysis workflow

The WDL version of [GeneLab bioinformatics processing pipeline for Illumina amplicon sequencing data](https://github.com/nasa/GeneLab_Data_Processing/tree/amplicon-add-runsheet-visualizations/Amplicon/Illumina)

## Running Workflow in Cromwell

Description of the files:
 - `AmpIllumina.wdl` file: the WDL file for workflow definition
 - `test_input.json` file: the example input for the WDL workflow
 - `config.json` file: the conf file for Snakemake of the Illumina amplicon analysis workflow.

## The Docker image and Dockerfile can be found here

[bioedge/ampillumina:1.2.0](https://hub.docker.com/r/bioedge/ampillumina)

## Input files

`test_input.json`

```json
{
    "AmpIllumina.config_json": "/path/to/Illumina/config.json"
    "AmpIllumina.OSD_id":""
    "AmpIllumina.specify_runsheet":""
}
```

`config.json`

```json
{
    "isa_archive":"",
    "runsheet":"/path/to/runsheet.csv",
    "raw_reads_dir": "/path/to/raw-reads/",
    "trim_primers": "TRUE",
    "anchor_primers":"TRUE",
    "primers_linked": "TRUE",
    "discard_untrimmed": "TRUE",
    "target_region": "16S",
    "concatenate_reads_only":"FALSE",
    "left_trunc": 0,
    "right_trunc": 0,
    "left_maxEE": 1,
    "right_maxEE": 1,
    "min_cutadapt_len": 130, 
    "output_prefix": "",
    "info_out_dir":"/path/to/workflow_output/Processing_Info/",
    "fastqc_out_dir": "/path/to/workflow_output/FastQC_Outputs/",
    "trimmed_reads_dir": "/path/to/workflow_output/Trimmed_Sequence_Data/",
    "filtered_reads_dir": "/path/to/workflow_output/Filtered_Sequence_Data/",
    "final_outputs_dir": "/path/to/workflow_output/Final_Outputs/",
    "plots_dir":"/path/to/workflow_output/Final_Outputs/Plots/"

}
```

## Test Data

[Test data](https://figshare.com/ndownloader/files/39537235)

[runsheet.csv for test data](https://raw.githubusercontent.com/LANL-Bioinformatics/NASA_GeneLab_workflows/feedback_edits/Amplicon/Illumina/runsheet.csv)

The Runsheet is a csv file that contains the metadata required for processing amplicon sequencing datasets through GeneLab's GeneLab Illumina amplicon sequencing data processing pipeline (AmpIllumina). Please see [here](https://github.com/nasa/GeneLab_Data_Processing/tree/amplicon-add-runsheet-visualizations/Amplicon/Illumina/Workflow_Documentation/SW_AmpIllumina-A/examples/runsheet) for Specification



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
│   ├── taxonomy.tsv
│   ├── Plots
│   │   ├── PCoA
│   │   │   ├── PCoA_w_labels.png
│   │   │   └── PCoA_without_labels.png
│   │   ├── color_legend.png
│   │   ├── de
│   │   │   ├── differential_abundance
│   │   │   │   ├── Ground_Control_&_non-irradiated_vs_Space_Flight_&_space_radiation.csv
│   │   │   │   └── Space_Flight_&_space_radiation_vs_Ground_Control_&_non-irradiated.csv
│   │   │   ├── normalized_counts.tsv
│   │   │   └── volcano
│   │   │       ├── volcano_Ground_Control_&_non-irradiated_vs_Space_Flight_&_space_radiation.png
│   │   │       └── volcano_Space_Flight_&_space_radiation_vs_Ground_Control_&_non-irradiated.png
│   │   ├── dendrogram
│   │   │   └── dendrogram_by_group.png
│   │   ├── rarefaction
│   │   │   └── rarefaction.png
│   │   ├── richness
│   │   │   ├── richness_by_group.png
│   │   │   └── richness_by_sample.png
│   │   └── taxonomy
│           ├── relative_classes.png
│           └── relative_phyla.png
├── Processing_Info
│   ├── R-processing.log
│   ├── R-visualizations.log
│   ├── Snakefile
│   ├── all-benchmarks.tsv
│   ├── benchmarks
│   │   ├── combine_cutadapt_logs_and_summarize-benchmarks.tsv
│   │   ├── etc
│   ├── config
│   │   └── multiqc.config
│   ├── config.yaml
│   ├── envs
│   │   ├── R.yaml
│   │   ├── R_visualizations.yaml
│   │   ├── cutadapt.yaml
│   │   └── qc.yaml
│   ├── runsheet.csv
│   ├── scripts
│   │   ├── Illumina-PE-R-processing.R
│   │   ├── Illumina-R-visualizations.R
│   │   ├── Illumina-SE-R-processing.R
│   │   ├── combine-benchmarks.sh
│   │   ├── copy_info.py
│   │   └── run_workflow.py
│   └── unique-sample-IDs.txt


```

## Notes
* make sure the raw reads with suffix _R1_raw.fastq.gz or _R2_raw.fastq.gz as defined in runsheet.csv
* adjust minimum length threshold for cutadapt in config.json. If too stringent, there will be no reads for downstream analysis.
