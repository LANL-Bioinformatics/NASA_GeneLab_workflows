version 1.0
workflow AmpIllumina{
    input{
        File config_json
        String container = "bioedge/ampillumina:1.0.1"
        }

    call read_config{
        input:
        config_json = config_json,
        container = container
    }
    
    call AmpIllumina_sm{
        input:
        config_json = config_json,
        output_prefix = read_config.output_prefix,
        fastqc_out_dir = read_config.fastqc_out_dir,
        trimmed_reads_dir = read_config.trimmed_reads_dir,
        filtered_reads_dir = read_config.filtered_reads_dir,
        final_outputs_dir = read_config.final_outputs_dir,
        container = container
    }

    output{
        File zipped_output = AmpIllumina_sm.zipped_output
        Array[File] json_file = AmpIllumina_sm.json_files
    }
    
}

task read_config{
    input{
        File config_json
        String container
    } 
    
    command <<<
    cp ~{config_json} config.json

    jq -r '.output_prefix' config.json
    jq -r '.fastqc_out_dir' config.json
    jq -r '.trimmed_reads_dir' config.json
    jq -r '.filtered_reads_dir' config.json
    jq -r '.final_outputs_dir' config.json

    >>>

    output{
        Array[String] output_lines = read_lines(stdout())
        String output_prefix = output_lines[0]
        String fastqc_out_dir = output_lines[1]
        String trimmed_reads_dir = output_lines[2]
        String filtered_reads_dir = output_lines[3]
        String final_outputs_dir = output_lines[4]
    }
    runtime{
        docker: container
    }
}


task AmpIllumina_sm{
    input{
        File config_json
        String output_prefix
        String fastqc_out_dir
        String trimmed_reads_dir
        String filtered_reads_dir 
        String final_outputs_dir
        String container
    }
    
    command <<<
    # run pipeline
    cp -r /data/SW_AmpIllumina-A_1.0.1/* .
    cp ~{config_json} config.json
    sed -i -e 's/config.yaml/config.json/' Snakefile 
    export SNAKEMAKE_OUTPUT_CACHE=$PWD
    snakemake --use-conda --conda-prefix /opt/conda/envs -j 2 -p

    # tsv to json
    python <<CODE

    import pandas as pd
    from pathlib import Path

    directory_path = Path('~{final_outputs_dir}')
    tsv_files = list(directory_path.glob('*.tsv'))

    # Print the list of TSV files
    for tsv_file in tsv_files:
        tsv_basename = Path(tsv_file).stem
        json_file = tsv_basename + ".json"
        df = pd.read_csv(tsv_file, delimiter='\t')
        df.to_json(Path(directory_path,json_file), orient='records')
    CODE

    # zip output
    dir=$(dirname  ~{final_outputs_dir})
    zip -r ~{output_prefix}_outdirs.zip \
    ~{fastqc_out_dir} ~{trimmed_reads_dir} ~{filtered_reads_dir} ~{final_outputs_dir}
    cp -f ~{output_prefix}_outdirs.zip $dir/

    >>>
    output{
        String AmpIllumina_final_outputs_dir = "~{final_outputs_dir}"
        Array[File] json_files = glob('~{final_outputs_dir}/*.json')
        File zipped_output = "~{output_prefix}_outdirs.zip"
    }

    runtime{
        docker: container
    }
}



