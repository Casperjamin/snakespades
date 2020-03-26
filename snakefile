# quick n dirty workflow to generate assemblies using spades

configfile: "config/config.yaml"
configfile: "samples/samples.yaml"
SAMPLES = config['SAMPLES']

conda: "envs/start.yaml"

rule all:
    input:
        expand("results/{sample}/assembly/assembly.fasta", sample = SAMPLES)





rule spades:
    input:
        forward = lambda wildcards: SAMPLES[wildcards.sample]['forward'],
        reverse = lambda wildcards: SAMPLES[wildcards.sample]['reverse']
    output:
        "results/{sample}/assembly/assembly.fasta"
    singularity:
        "docker://casperjamin/spades:latest"
    threads: 16
    params:
        "results/{sample}/assembly"
    shell:
        "spades -1 {input.forward} -2 {input.reverse} -o {params} "
        "--careful --cov-cutoff auto "
        "-t {threads} "
