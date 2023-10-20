version 1.0
workflow AmpIllumina{
    input{
        String config_json
        String container = "bioedge/ampillumina:1.0.1"
        }

    call read_config{
        input:
        config_json = config_json,
        container = container
    }
    
    call AmpIllumina_sm{
        input:
        output_prefix = read_config.output_prefix,
        fastqc_out_dir = read_config.fastqc_out_dir,
        trimmed_reads_dir = read_config.trimmed_reads_dir,
        filtered_reads_dir = read_config.filtered_reads_dir,
        final_outputs_dir = read_config.final_outputs_dir,
        container = container
    }

    call tsv_to_json{
        input:
        final_outputs_dir = read_config.final_outputs_dir,
        container = container
    }

    output{
        File zipped_output = AmpIllumina_sm.zipped_output
        Array[File] json_file = tsv_to_json.json_file
    }
    
}

task read_config{
    input{
        String config_json
        String container
    } 
    
    command <<<
    cp ~{config_json} config.json

    echo "$(jq -r '.output_prefix' config.json)"
    echo "$(jq -r '.fastqc_out_dir' config.json)"
    echo "$(jq -r '.trimmed_reads_dir' config.json)"
    echo "$(jq -r '.filtered_reads_dir' config.json)"
    echo "$(jq -r '.final_outputs_dir' config.json)"

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
        String output_prefix
        String fastqc_out_dir
        String trimmed_reads_dir
        String filtered_reads_dir 
        String final_outputs_dir
        String container
    }
    command <<<

    sed -ie 's/config.yaml/config.json/' Snakefile
    snakemake --use-conda --conda-prefix /opt/conda/envs -j 2 -p

    zip -r ~{output_prefix}_outdirs.zip \
    ~{fastqc_out_dir} ~{trimmed_reads_dir} ~{filtered_reads_dir} ~{final_outputs_dir}

    >>>
    output{
        File zipped_output = "~{output_prefix}_outdirs.zip"
    }

    runtime{
        docker: container
    }
}

task tsv_to_json{
    input{
        String final_outputs_dir
        String container
    }
    command <<<
        python <<CODE

        import pandas as pd
        from pathlib import Path

        directory_path = Path('~{final_outputs_dir}')
        tsv_files = list(directory_path.glob('*.tsv'))

        # Print the list of TSV files
        for tsv_file in tsv_files:
            tsv_basename = Path(tsv_file_path).stem
            json_file = tsv_basename + ".json"
            df = pd.read_csv(tsv_file, delimiter='\t')
            df.to_json(json_file, orient='records', lines=True)
        CODE
    >>>
    output{
        Array[File] json_file = glob('~{final_outputs_dir}/*.json')
    }
    runtime{
        docker: container
    }

}

