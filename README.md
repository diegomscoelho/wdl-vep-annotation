# code-challenge-wdl-vep-annotation

## Pre-requisites
    * Cromwell (https://github.com/broadinstitute/cromwell/releases)
    * Docker (https://docs.docker.com/engine/install/ubuntu/)

## Usage example

```
# Before running:
    - Fill run_vep.inputs.json with necessary information, i.e:
    {
        "run_vep.vcf_index": "<PATH-TO>/small.vcf.gz.tbi",
        "run_vep.vcf": "<PATH-TO>/small.vcf.gz",
        "run_vep.chrs": ["4","10","22"],
        "run_vep.CADD_REF": "<PATH-TO>/cadd_snv.tsv.gz",
        "run_vep.CADD_IDX": "<PATH-TO>/cadd_snv.tsv.gz.tbi"

    }
    OR
    {
        "run_vep.vcf_index": "<PATH-TO>/small.vcf.gz.tbi",
        "run_vep.vcf": "<PATH-TO>/small.vcf.gz",
        "run_vep.CADD_REF": "<PATH-TO>/cadd_snv.tsv.gz",
        "run_vep.CADD_IDX": "<PATH-TO>/cadd_snv.tsv.gz.tbi"
    }

    - Zip tools foder to a .zip, i.e:
    `zip -r tools.zip tools/`
    - Start cromwell-server, i.e:
    `java -jar cromwell-{VERSION}.jar server`

# Deploy job via:

## Via swagger - http://localhost:8000/swagger/index.html?url=/swagger/cromwell.yaml

### Select POST in /api/workflows/{version}
### Add:
    * workflowInputs (run_vep.inputs.json) - Need to fill
    * workflowInputs (run_vep.wdl)
    * workflowDependencies (tools) - Folder need to be zipped

## OR

## Via curl
curl -X POST "http://localhost:8000/api/workflows/v1" -H "accept: application/json" -H "Content-Type: multipart/form-data" -F "workflowSource=@<PATH-TO/WORKFLOW.WDL>" -F "workflowInputs=@<PATH-TO/WORKFLOW.INPUTS.JSON>;type=application/json" -F "workflowDependencies=@<PATH-TO/TOOLS.ZIP>;type=text/markdown"