# quick n dirty workflow to generate assemblies using spades

configfile: "config/config.yaml"
configfile: "samples/samples.yaml"
SAMPLES = config['SAMPLES']

conda: "envs/start.yaml"

spades = "~/tools/SPAdes-3.7.1-Linux/bin/spades.py"

rule all:
    input:
        expand("results/{sample}/assembly/assembly.fasta", sample = SAMPLES)

rule trimming:
    input:
        forward = lambda wildcards: SAMPLES[wildcards.sample]['forward'],
        reverse = lambda wildcards: SAMPLES[wildcards.sample]['reverse']
    output:
        forward = "results/data/{sample}/fastp/{sample}_R1.fastq.gz",
        reverse = "results/data/{sample}/fastp/{sample}_R2.fastq.gz",
        json = "results/data/{sample}/fastp/{sample}.json",
        html = "results/data/{sample}/fastp/{sample}.html"
    conda:
        "envs/fastp.yaml"
    threads: 16
    resources: time_min=300, mem_mb=8000, cpus=16
    log:
        "logs/fastp/{sample}/log.txt"
    shell:
        "fastp -w {threads} -i {input.forward} -I {input.reverse} -o {output.forward} -O {output.reverse}"
	" --json {output.json} --html {output.html}"
	" 2> {log}"



rule spades:
    input:
        forward = "results/data/{sample}/fastp/{sample}_R1.fastq.gz",
        reverse = "results/data/{sample}/fastp/{sample}_R2.fastq.gz",
    output:
        "results/{sample}/assembly/assembly.fasta"
    singularity:
        "docker://casperjamin/spades:latest"
    threads: 16

    resources: time_min=300, mem_mb=8000, cpus=16
    params:
        "results/{sample}/assembly"
    conda: "envs/start.yaml"
    shell:
        "python {spades} -1 {input.forward} -2 {input.reverse} -o {params} "
        "--careful --cov-cutoff auto "
        "-t {threads} "
