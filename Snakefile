# manyeconomists
#
# researcher_id: 579

# --- Variable Declarations ---# 
runR = "Rscript --no-save --no-restore --verbose"

# For TWFE
FIXEFF        = glob_wildcards("src/model-specs/twfe/twfe_fe_{fname}.json").fname
CTRLS         = glob_wildcards("src/model-specs/twfe/twfe_controls_{fname}.json").fname

# For DiD ala CSA(2021)
DID_CTRLS         = glob_wildcards("src/model-specs/did/model_controls_{fname}.json").fname

#--- all --- 

rule all: 
    input: 
        did = expand("out/analysis/did/did_ctrl_{iCtrl}.rds",
                iCtrl = DID_CTRLS
                ),
        twfe =  expand("out/analysis/twfe/twfe_fe_{iFE}_ctrl_{iControl}.rds",
                iFE = FIXEFF,
                iControl = CTRLS
                )



# ---- MODELLING ---- #
# --- DID ala CSA(2021) ---# 
rule estimate_did:
    input:
        expand("out/analysis/did/did_ctrl_{iCtrl}.rds",
                iCtrl = DID_CTRLS
                )

rule did:
    input: 
        script        = "src/analysis/did_csa.R",
        data          = "out/data/estimation_sample.csv",
        model_base    = "src/model-specs/did/model_base.json",
        model_ctrl    = "src/model-specs/did/model_controls_{iCtrl}.json" 
    output:
        model = "out/analysis/did/did_ctrl_{iCtrl}.rds"
    log:
        "log/analysis/did/did_ctrl_{iCtrl}.Rout"
    shell: 
        "{runR} {input.script} {input.data} \
            {input.model_base} {input.model_ctrl} \
            {output.model} > {log} 2>&1"

# --- TWFE Models --- # 
rule estimate_twfe:
    input:
        expand("out/analysis/twfe/twfe_fe_{iFE}_ctrl_{iControl}.rds",
                iFE = FIXEFF,
                iControl = CTRLS
                )

rule twfe:
    input: 
        script      = "src/analysis/twfe.R",
        data        = "out/data/estimation_sample.csv",
        model_base  = "src/model-specs/twfe/twfe_main.json",
        model_fe    = "src/model-specs/twfe/twfe_fe_{iFE}.json",
        model_ctrl  = "src/model-specs/twfe/twfe_controls_{iControl}.json" 
    output:
        model = "out/analysis/twfe/twfe_fe_{iFE}_ctrl_{iControl}.rds"
    log:
        "log/analysis/twfe/twfe_fe_{iFE}_ctrl_{iControl}.Rout"
    shell: 
        "{runR} {input.script} {input.data} \
            {input.model_base} {input.model_fe} {input.model_ctrl} \
            {output.model} > {log} 2>&1"

# --- Data Cleaning --- # 
# codes up variables from NickCHK to have same name
# as what we have in previous tasks
rule clean_estimation_sample:
    input: 
        script = "src/data-mgt/clean_daca_sample.R",
        data = "out/data/daca_sample.csv",
    output:
        data = "out/data/estimation_sample.csv",
    log:
        "log/data-mgt/clean_daca_sample.Rout"
    shell:
        "{runR} {input.script} {input.data} {output.data}  > {log} 2>&1"


# --- Download the data --- # 
# data comes from a Github repo, so we can download via a script rather than point and 
# clicking our way through IPUMS

rule download_data:
    input:
        script = "src/data-mgt/download_data.R"
    output:
        data = "out/data/daca_sample.csv"
    params:
        url = "https://raw.githubusercontent.com/NickCH-K/repl_data/main/prepared_data_numeric_version.csv"
    log:
        "log/data-mgt/download_data.Rout"
    shell:
        "{runR} {input.script} {params.url} {output.data} > {log} 2>&1"

# --- Sub Rules --- #
# Include all other Snakefiles that contain rules that are part of the project
include: "renv.smk"

# --- Workflow Viz --- # 
## rulegraph          : create the graph of how rules piece together 
rule rulegraph:
    input:
        "Snakefile"
    output:
        "rulegraph.pdf"
    shell:
        "snakemake --rulegraph | dot -Tpdf > {output}"

## rulegraph_to_png
rule rulegraph_to_png:
    input:
        "rulegraph.pdf"
    output:
        "rulegraph.png"
    shell:
        "pdftoppm -png {input} > {output}"

## dag                : create the DAG as a pdf from the Snakefile
rule dag:
    input:
        "Snakefile"
    output:
        "dag.pdf"
    shell:
        "snakemake --dag | dot -Tpdf > {output}"
