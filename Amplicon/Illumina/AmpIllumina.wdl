version 1.0
workflow AmpIllumina{
    input{
        File config_json
        String OSD_id=""
        File? specify_runsheet
        String container = "bioedge/ampillumina:1.2.0"
    }

    call read_config{
        input:
        config_json = config_json,
        container = container
    }
    call json_to_yaml{
        input:
        config_json = config_json,
        container = container
    }
    call AmpIllumina_sm{
        input:
        #config_yaml = json_to_yaml.config_yaml,
        OSD_id = OSD_id,
        specify_runsheet = specify_runsheet,
        target = read_config.target,
        run_sheet = read_config.run_sheet_file,
        output_prefix = read_config.output_prefix,
        fastqc_out_dir = read_config.fastqc_out_dir,
        trimmed_reads_dir = read_config.trimmed_reads_dir,
        filtered_reads_dir = read_config.filtered_reads_dir,
        final_outputs_dir = read_config.final_outputs_dir,
        primers_linked = read_config.primers_linked,
        anchor_primers = read_config.anchor_primers,
        raw_reads_dir = read_config.raw_reads_dir,
        discard_untrimmed = read_config.discard_untrimmed,
        trim_primers = read_config.trim_primers,
        concatenate_reads_only = read_config.concatenate_reads_only,
        left_trunc = read_config.left_trunc,
        right_trunc = read_config.right_trunc,
        left_maxEE = read_config.left_maxEE,
        right_maxEE = read_config.right_maxEE,
        min_cutadapt_len = read_config.min_cutadapt_len,
        
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
    jq -r '.runsheet' config.json
    jq -r '.primers_linked' config.json
    jq -r '.anchor_primers' config.json
    jq -r '.raw_reads_dir' config.json
    jq -r '.discard_untrimmed' config.json
    jq -r '.trim_primers' config.json
    jq -r '.concatenate_reads_only' config.json
    jq -r '.left_trunc' config.json
    jq -r '.right_trunc' config.json
    jq -r '.left_maxEE' config.json
    jq -r '.right_maxEE' config.json
    jq -r '.min_cutadapt_len' config.json
    jq -r '.target_region' config.json


    >>>

    output{
        Array[String] output_lines = read_lines(stdout())
        String output_prefix = output_lines[0]
        String fastqc_out_dir = output_lines[1]
        String trimmed_reads_dir = output_lines[2]
        String filtered_reads_dir = output_lines[3]
        String final_outputs_dir = output_lines[4]
        File?  run_sheet_file = output_lines[5]
        String primers_linked = output_lines[6]
        String anchor_primers = output_lines[7]
        String raw_reads_dir = output_lines[8]
        String discard_untrimmed = output_lines[9]
        String trim_primers = output_lines[10]
        String concatenate_reads_only = output_lines[11]
        String left_trunc = output_lines[12]
        String right_trunc = output_lines[13]
        String left_maxEE = output_lines[14]
        String right_maxEE = output_lines[15]
        String min_cutadapt_len = output_lines[16]
        String target = output_lines[17]
    }
    runtime{
        docker: container
    }
}

task json_to_yaml{
    input{
        File config_json
        String container
    }
    command <<<
    
    python <<CODE
    import json
    import yaml
    with open("~{config_json}",'r') as f:
        config = json.load(f)
    with open('config.yaml', 'w') as yaml_file:
        yaml.dump(config, yaml_file)
    CODE

    >>>

    output{
        File config_yaml = "config.yaml"
    }

    runtime{
        docker: container
    }
}

task AmpIllumina_sm{
    input{
        #File config_yaml
        String OSD_id
        File? run_sheet
        File? specify_runsheet
        String target 
        String output_prefix
        String fastqc_out_dir
        String trimmed_reads_dir
        String filtered_reads_dir 
        String final_outputs_dir
        String container
        String primers_linked
        String anchor_primers
        String raw_reads_dir
        String discard_untrimmed
        String trim_primers
        String concatenate_reads_only
        String left_trunc
        String right_trunc
        String left_maxEE
        String right_maxEE
        String min_cutadapt_len
    }
    
    command <<<
    # run pipeline
    cp -r /data/SW_AmpIllumina-A_1.2.0/* .
    ln -s ~{raw_reads_dir} raw_reads
    
    export SNAKEMAKE_OUTPUT_CACHE=$PWD

    outdir=$(dirname  ~{final_outputs_dir})
    if [ -z "~{OSD_id}" ]
    then
        if [ -f "~{run_sheet}" ]
        then 
            python ./scripts/run_workflow.py --output-prefix "~{output_prefix}" --outputDir "$outdir" --left-trunc "~{left_trunc}" --right-trunc "~{right_trunc}" --left-maxEE "~{left_maxEE}" --right-maxEE "~{right_maxEE}" --concatenate_reads_only "~{concatenate_reads_only}" --trim-primers "~{trim_primers}" --discard-untrimmed "~{discard_untrimmed}" --min_trimmed_length "~{min_cutadapt_len}" --anchor-primers "~{anchor_primers}" --primers-linked "~{primers_linked}" --runsheetPath ~{run_sheet} --run "snakemake --use-conda --conda-prefix /opt/conda/envs -j 4 -p"
        else
            echo "No OSD_id and No run_sheet."
        fi 
    else
        if [ -f "~{specify_runsheet}" ]
        then
            python ./scripts/run_workflow.py --target "~{target}" --specify-runsheet "~{specify_runsheet}" --output-prefix "~{output_prefix}" --outputDir "$outdir" --left-trunc "~{left_trunc}" --right-trunc "~{right_trunc}" --left-maxEE "~{left_maxEE}" --right-maxEE "~{right_maxEE}" --concatenate_reads_only "~{concatenate_reads_only}"  --trim-primers "~{trim_primers}" --discard-untrimmed "~{discard_untrimmed}" --min_trimmed_length "~{min_cutadapt_len}"  --anchor-primers "~{anchor_primers}" --primers-linked "~{primers_linked}" --OSD ~{OSD_id} --run "snakemake --use-conda --conda-prefix /opt/conda/envs -j 4 -p"

        else
            python ./scripts/run_workflow.py --output-prefix "~{output_prefix}" --outputDir "$outdir" --left-trunc "~{left_trunc}" --right-trunc "~{right_trunc}" --left-maxEE "~{left_maxEE}" --right-maxEE "~{right_maxEE}" --concatenate_reads_only "~{concatenate_reads_only}"  --trim-primers "~{trim_primers}" --discard-untrimmed "~{discard_untrimmed}" --min_trimmed_length "~{min_cutadapt_len}"  --anchor-primers "~{anchor_primers}" --primers-linked "~{primers_linked}" --OSD ~{OSD_id} --run "snakemake --use-conda --conda-prefix /opt/conda/envs -j 4 -p"
        fi

    fi

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
    cd "$outdir" || true
    zip -r ~{output_prefix}_outdirs.zip *
    
   

    >>>
    output{
        String AmpIllumina_final_outputs_dir = "~{final_outputs_dir}"
        Array[File] json_files = glob('~{final_outputs_dir}/*.json')
        File zipped_output = "~{final_outputs_dir}/../~{output_prefix}_outdirs.zip"
    }

    runtime{
        docker: container
    }
}



