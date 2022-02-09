params.outdir = "results/"

process findSequences {
    input:
    path pyscript
    path pred_file
    val feature_id
    
    output:
    path "seq_ranges_*.txt", emit: ranges
    
    script:
    suffix = "seq_ranges_${pred_file.getFileName()}"
    """
    python3 ${pyscript} ${pred_file} ${suffix} ${feature_id}
    """
}

process extractSequences {
    input:
    path pyscript
    path ranges
    path fasta
    
    output:
    path "seqs_*.fa"
    
    script:
    outname = "seqs_${ranges.getFileName()}".split('\\.')[0] + "__" + "${fasta.getFileName()}".split('\\.')[0] + ".fa"
    """
    python3 ${pyscript} ${ranges} ${fasta} ${outname}
    """
}

process findAndExtractPair {
    input:
    path findscript
    path extrscript
    tuple val(id) path(predFile) path(fastaFile)
    val featureID

    output:
    path "seqs_pair_*.fa"

    script:
    outname = "seqs_pair_${predFile.getFileName().toString().split("\\.")[0]}_${fastaFile.getFileName().toString().split("\\.")[0]}.fa"
    """
    python3 ${findscript} ${predFile} seqs.txt ${featureID}
    python3 ${extrscript} seqs.txt ${fastaFile} ${outname}
    """

}

process countKmers {
    input:
    path pyscript
    path seqs
    val kmer

    output:
    path "seq_kmers_*.txt"
    
    script:
    """
    #!/usr/bin/env bash
    python3 ${pyscript} ${seqs} "seq_kmers_${seqs.getFileName().toString().split("\\.")[0]}.txt" ${kmer}
    """
}

process sumKmers {
    publishDir params.outdir, mode: "move", overwrite: false

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