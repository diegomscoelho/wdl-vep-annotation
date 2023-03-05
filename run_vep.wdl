## # VEP annotated VCF files
##
## This WDL workflow annotates a VCF using VEP workflow.
## The workflow takes splits VCF by chromosomes.
## Runs VEP in all those split VCFs and merge all of them in a single VCF.
##
## ## LICENSING
##
## #### MIT License
##
## Copyright 2023 Diego M. Coelho

version 1.0

import "./tools/bcftools.wdl"
import "./tools/vep.wdl"

workflow run_vep {
    input {
        File vcf
        File vcf_index
        File CADD_REF
        File CADD_IDX
        Array[String]? chrs
    }

    Float vcf_size = size(vcf, "GiB")
    Int calc_memory = 2 * ceil(vcf_size)
    Int memory_gb = if calc_memory > 2 then calc_memory else 2
    Int disk_size = 10 + ceil(vcf_size * 2)

    parameter_meta {
        vcf: "VCF that will be split. Currently supports sorted and bgzipped file"
        chrs: "Comma-separated list of chromosomes to generate. i.e. 1,2,... (Optional)"
    }

    # Conditional
    if(!defined(chrs)){
        call bcftools.readChrVCF {
            input:
                vcf=vcf,
                vcf_index=vcf_index,
                memory_gb=memory_gb,
                disk_size=disk_size,
                ncpu=1
        }
    }

    Array[String] chromosomes = select_first([chrs, readChrVCF.chrs])

    # Loop over all chromosomes
    scatter (chr in chromosomes) {
        call bcftools.splitVCF {
            input:
                chr=chr,
                vcf=vcf,
                vcf_index=vcf_index,
                memory_gb=memory_gb,
                disk_size=disk_size,
                ncpu=1
        }

        call vep.runVEP {
            input:
                vcf=splitVCF.split_vcf,
                vcf_index=splitVCF.split_vcf_index,
                CADD_REF=CADD_REF,
                CADD_IDX=CADD_IDX,
                memory_gb=memory_gb,
                disk_size=disk_size,
                ncpu=4
        }
    }

    call bcftools.mergeVCF {
        input:
            vcfs=runVEP.vcf_vep,
            vcfs_index=runVEP.vcf_vep_index,
            memory_gb=memory_gb,
            disk_size=disk_size,
            ncpu=1
    }

    output {
        File vep_vcf = mergeVCF.vcf
        File vep_vcf_index = mergeVCF.vcf_index
        Array[File] vep_vcf_summary = runVEP.vcf_vep_summary
    }
}
