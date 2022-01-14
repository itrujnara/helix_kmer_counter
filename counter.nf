#!/usr/bin/env nextflow

params.kmer = 3
params.fasta = "/data/seqence.fa"

process findSequences {
    input:
    file "prediction.txt" from params.fasta
    
    output:
    file "matches.txt" into matches_ch
    
    script:
    """
    #!/usr/bin/env python
    # paste selector script here when ready
    """
}

process extractSequences {
    input:
    file "matches.txt" from matches_ch
    
    output:
    file "seqs.fa" into seq_ch
    
    script:
    """
    #!/usr/bin/env python
    # todo
    """
}

process countKmers {
    input:
    file "seqs.fa" from seq_ch
    
    script:
    """
    #!/usr/bin/env python
    # todo
    """
}
