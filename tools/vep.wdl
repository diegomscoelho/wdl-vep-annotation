# VEP WDL
# This WDL tool uses VEP to annotate VCF files.
# For documentation, please see https://www.ensembl.org/info/docs/tools/vep/index.html.

version 1.0

task runVEP {

    input {
        File vcf
        File vcf_index
        File CADD_REF
        File CADD_IDX
        Int memory_gb
        Int disk_size
        Int ncpu
    }

    String prefix = basename(vcf, ".vcf.gz")

    command <<<
        vcf="~{vcf}"
        vep -i ~{vcf} -o ~{prefix}_vep.vcf.gz \
        --vcf --force_overwrite --database \
        --compress_output bgzip --format vcf \
        --plugin Blosum62 \
        --plugin CSN \
        --plugin Carol \
        --plugin CADD,~{CADD_REF} \
        --plugin Downstream \
        --plugin LoFtool \
        --plugin LOVD \
        --plugin SingleLetterAA \
        --plugin SpliceRegion \
        --plugin TSSDistance

        tabix -p vcf ~{prefix}_vep.vcf.gz

    >>>

    output {
        File vcf_vep = "~{prefix}_vep.vcf.gz"
        File vcf_vep_index = "~{prefix}_vep.vcf.gz.tbi"
        File vcf_vep_summary = "~{prefix}_vep.vcf.gz_summary.html"
    }

    runtime {
        memory: memory_gb + " GB"
        cpu: ncpu
        disks: "local-disk " + disk_size + " HDD"
        docker: 'ensemblorg/ensembl-vep:latest'
    }

    meta {
        author: "Diego M. Coelho"
        email: "diegomscoelho@gmail.com"
        description: "This WDL tool outputs VEP annotated VCF"
    }

}