#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

params.kmer = 3
params.fasta = "/data/seqence.fa"
params.pred = "/data/prediction.txt"

process findSequences {
    input:
    path "prediction.txt"
    
    output:
    stdout
    
    script:
    """
    #!/usr/bin/env python
    # paste selector script here when ready
    """
}

process extractSequences {
    input:
    stdin
    path "inseqs.fa"
    
    output:
    stdout
    
    script:
    """
    #!/usr/bin/env python
    # todo
    """
}

process countKmers {
    input:
    stdin
    
    script:
    """
    #!/usr/bin/env python
    # todo
    """
}

workflow {
    findSequences(params.pred)
    extractSequences(findSequences.out, params.fasta)
    countKmers(extractSequences.out)
}
