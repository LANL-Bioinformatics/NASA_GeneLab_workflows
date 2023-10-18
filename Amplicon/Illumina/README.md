
The WDL version of [GeneLab bioinformatics processing pipeline for Illumina amplicon sequencing data](https://github.com/nasa/GeneLab_Data_Processing/tree/master/Amplicon/Illumina)

## Docker run cmd: 
```
docker run --rm -it -v $PWD/raw-reads:/data/Raw_Sequence_Data -v $PWD/unique-sample_IDs.txt:/data/SW_AmpIllumina-A_1.0.1/unique-sample-IDs.txt ampillumina  snakemake --use-conda --conda-prefix /opt/conda/envs -j 2 -p
```

## Notes
* bind the data directory to /data/Raw_Sequence_Data or full path to the dir
* have unique-sample-id save to /data/SW_AmpIllumina-A_1.0.1/unique-sample-IDs.txt or full path to the file
* make sure the raw reads with suffix _R1_raw.fastq.gz or _R2_raw.fastq.gz
* adjust minimum length threshold for cutadapt in /data/SW_AmpIllumina-A_1.0.1/config.yaml
* or write GUI json parameter to /data/SW_AmpIllumina-A_1.0.1/config.json
    * use json instead of yaml in Snakefile: configfile: "config.yaml"  > configfile: "config.json"

