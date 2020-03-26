# quick n dirty workflow to generate assemblies using spades

configfile: "config/config.yaml"
SAMPLES = config['SAMPLES']

print(SAMPLES)

rule all:
    input:
        expand("results/{sample}/assembly/assembly.fasta", sample = SAMPLES)



rule trimming:
    input:
        forward = lambda wildcards: SAMPLES[wildcards.sample]['forward'],
        reverse = lambda wildcards: SAMPLES[wildcards.sample]['reverse']
    output:

        json = "results/data/{sample}/fastp/{sample}.json",
        html = "results/data/{sample}/fastp/{sample}.html"
    singularity:
        "docker://casperjamin/fastp:latest"
    threads: 16
    log:
        "logs/fastp/{sample}/log.txt"
    shell:
        """
        which fastp
        """


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
        "spades.py -1 {input.forward} -2 {input.reverse} -o {params} "
        "--careful --cov-cutoff auto "
        "-t {threads} "
