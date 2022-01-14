#!/usr/bin/env nextflow

params.kmer = 3
params.fasta = "/data/seqence.fa"

process findHelices {
    input:
    file "sequence.fa" from params.fasta
    
    output:
    file "matches.fa" into matches_ch
    
    script:
    """
    #!/usr/bin/env python
    #todo, possibly Alessio's
    """
}

process extractSequences {
    input:
    file "matches.fa" from matches_ch
    
    output:
    file "seqs.fa" into seq_ch
    
    script:
    """
    #!/usr/bin/env python
    #todo
    """
}

process countKmers {
    input:
    file "seqs.fa" from seq_ch
    
    script:
    """
    #!/usr/bin/env python
    #todo
    """
}
