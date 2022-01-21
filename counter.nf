#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

params.kmer = 3
params.feature = "s"
params.fasta = "data/sequence.fa"
params.pred = "data/prediction.txt"
params.outfile = "results/kmers.txt"

process findSequences {
    input:
    path pyscript
    path pred_file
    val feature_id
    
    output:
    path "seq_ranges.txt"
    
    script:
    """
    #!/usr/bin/env bash
    python3 ${pyscript} ${pred_file} seq_ranges.txt ${feature_id}
    """
}

process extractSequences {
    input:
    path pyscript
    path ranges
    path fasta
    
    output:
    path "seqs.txt"
    
    script:
    """
    #!/usr/bin/env bash
    python3 ${pyscript} ${ranges} ${fasta} seqs.txt
    """
}

process countKmers {
    input:
    path pyscript
    path seqs
    val kmer

    output:
    path "seq_kmers.txt"
    
    script:
    """
    #!/usr/bin/env bash
    python3 ${pyscript} ${seqs} seq_kmers.txt ${kmer}
    """
}

process sumKmers {
    input:
    path pyscript
    path kmers

    output:
    path "total_kmers.txt"

    script:
    """
    #!/usr/bin/env bash
    python3 ${pyscript} ${kmers} total_kmers.txt
    """
}

workflow countHelixKmers {
    take:
    kmer
    feature_name
    prediction
    fasta

    main:
    findscript = params.SCRIPTS + "find_seqs.py"
    findSequences(findscript, (params.PARENT + prediction), feature_name)
    extrscript = params.SCRIPTS + "extract_seqs.py"
    extractSequences(extrscript, findSequences.out, (params.PARENT + fasta))
    countscript = params.SCRIPTS + "kmer_count.py"
    countKmers(countscript, extractSequences.out, kmer)
    sumscript = params.SCRIPTS + "sum_kmers.py"
    sumKmers(sumscript, countKmers.out)
    
    emit:
    countKmers.out
}

workflow {
    countHelixKmers(params.kmer, params.feature, params.pred, params.fasta)
    // print(countHelixKmers.out)
}
