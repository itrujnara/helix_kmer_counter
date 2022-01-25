#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

params.kmer = 3
params.feature = "s"
params.fasta = "data/sequence.fa"
params.pred = "data/prediction.txt"
params.outdir = "results/"

process findSequences {
    publishDir "tmp/findSequences"

    input:
    path pyscript
    path pred_file
    val feature_id
    
    output:
    path "seq_ranges*"
    
    script:
    """
    #!/usr/bin/env bash
    python3 ${pyscript} ${pred_file} "seq_ranges.txt" ${feature_id}
    """
}

process extractSequences {
    publishDir "tmp/extractSequences"

    input:
    path pyscript
    path ranges
    path fasta
    
    output:
    path "seqs.txt"
    
    script:
    """
    python3 ${pyscript} ${ranges} ${fasta} seqs.txt
    rm -rf $baseDir/tmp/findSequences
    """
}

process countKmers {
    publishDir "tmp/countKmers"

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
    rm -rf $baseDir/tmp/extractSequences
    """
}

process sumKmers {
    publishDir params.outdir

    input:
    path pyscript
    path kmers

    output:
    path "total_kmers.txt"

    script:
    """
    #!/usr/bin/env bash
    python3 ${pyscript} ${kmers} total_kmers.txt
    rm -rf $baseDir/tmp/countKmers
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
    //findSequences.out.view()
    extrscript = params.SCRIPTS + "extract_seqs.py"
    extractSequences(extrscript, findSequences.out, (params.PARENT + fasta))
    countscript = params.SCRIPTS + "kmer_count.py"
    countKmers(countscript, extractSequences.out, kmer)
    sumscript = params.SCRIPTS + "sum_kmers.py"
    sumKmers(sumscript, countKmers.out)
    
    emit:
    sumKmers.out
}

workflow {
    countHelixKmers(params.kmer, params.feature, params.pred, params.fasta)
    print(countHelixKmers.out)
}
