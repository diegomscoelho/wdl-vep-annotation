# BCFtools WDL
# This WDL tool uses BCFtools to perform simple tasks using VCF files.
# For documentation, please see https://samtools.github.io/bcftools/bcftools.html.

version 1.0

task readChrVCF {

    input {
        File vcf
        File vcf_index
        Int memory_gb
        Int disk_size
        Int ncpu
    }

    command <<<

        tabix -l ~{vcf}

    >>>

    output {
        Array[String] chrs = read_lines(stdout())
    }

    runtime {
        memory: memory_gb + " GB"
        cpu: ncpu
        disks: "local-disk " + disk_size + " HDD"
        docker: 'quay.io/biocontainers/bcftools:1.13--h3a49de5_0'
    }

    meta {
        author: "Diego M. Coelho"
        email: "diegomscoelho@gmail.com"
        description: "This WDL tool outputs splitted VCFs by chromosomes"
    }

}

task splitVCF {

    input {
        String chr
        File vcf
        File vcf_index
        Int memory_gb
        Int disk_size
        Int ncpu
    }

    command <<<

        bcftools view -r ~{chr} ~{vcf} -o split.~{chr}.vcf.gz -O z
        bcftools index -t split.~{chr}.vcf.gz

    >>>

    output {
        File split_vcf = "split.~{chr}.vcf.gz"
        File split_vcf_index = "split.~{chr}.vcf.gz.tbi"
    }

    runtime {
        memory: memory_gb + " GB"
        cpu: ncpu
        disks: "local-disk " + disk_size + " HDD"
        docker: 'quay.io/biocontainers/bcftools:1.13--h3a49de5_0'
    }

    meta {

        author: "Diego M. Coelho"
        email: "diegomscoelho@gmail.com"
        description: "This WDL tool outputs splitted VCFs by chromosomes"

    }

}

task mergeVCF {

    input {
        Array[File] vcfs
        Array[File] vcfs_index
        Int memory_gb
        Int disk_size
        Int ncpu
    }

    command <<<

        bcftools concat ~{sep=" " vcfs} -Oz -o temp.vcf.gz
        bcftools sort -Oz -o merged.vcf.gz temp.vcf.gz 
        bcftools  index -t merged.vcf.gz

    >>>

    output {
        File vcf = "merged.vcf.gz"
        File vcf_index = "merged.vcf.gz.tbi"
    }

    runtime {
        memory: memory_gb + " GB"
        cpu: ncpu
        disks: "local-disk " + disk_size + " HDD"
        docker: 'quay.io/biocontainers/bcftools:1.13--h3a49de5_0'
    }

    meta {

        author: "Diego M. Coelho"
        email: "diegomscoelho@gmail.com"
        description: "This WDL tool outputs splitted VCFs by chromosomes"

    }

}