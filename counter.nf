#!/usr/bin/env nextflow

include { ch_pairer } from "./channel_pairer.nf"
// include { pairer } from "./pairer.nf"

nextflow.enable.dsl = 2

params.kmer = 3
params.feature = "s"
params.pairing = "none"
params.fasta = "data/sequence.fa"
params.pred = "data/prediction.txt"
params.outdir = "results/"

process findSequences {
    input:
    path pyscript
    path pred_file
    val feature_id
    
    output:
    path "seq_ranges_*.txt", emit: ranges
    
    script:
    """
    python3 ${pyscript} ${pred_file} "seq_ranges_${pred_file.getFileName()}" ${feature_id}
    """
}

process extractSequences {
    input:
    path pyscript
    path ranges
    path fasta
    
    output:
    path "seqs_*.txt"
    
    script:
    """
    python3 ${pyscript} ${ranges} ${fasta} "seqs_${fasta.getFileName().toString().split("\\.")[0]}_${ranges.getFileName().toString().split("\\.")[0]}.txt"
    """
}

process findAndExtractPair {
    input:
    path findscript
    path extrscript
    tuple val(id) path(predFile) path(fastaFile)
    val featureID

    output:
    path "seqs_pair_*.txt"

    script:
    """
    python3 ${findscript} ${predFile} seqs.txt ${featureID}
    python3 ${extrscript} seqs.txt ${fastaFile} "seqs_pair_${predFile.getFileName().toString().split("\\.")[0]}_${fastaFile.getFileName().toString().split("\\.")[0]}.txt"
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
    python3 ${pyscript} ${seqs} "seq_kmers_${seqs.getFileName()}" ${kmer}
    """
}

process sumKmers {
    publishDir params.outdir, mode: "move", overwrite: false

    input:
    path pyscript
    path kmers

    output:
    path "total_kmers_*.txt"

    script:
    """
    #!/usr/bin/env bash
    python3 ${pyscript} ${kmers} "total_kmers_${kmers.getFileName()}"
    """
}

workflow countHelixKmers {
    take:
    kmer
    featName
    pairing
    prediction
    fasta

    main:
    // script finder
    findscript = params.SCRIPTS + "find_seqs.py"
    extrscript = params.SCRIPTS + "extract_seqs.py"
    countscript = params.SCRIPTS + "kmer_count.py"
    sumscript = params.SCRIPTS + "sum_kmers.py"

    if(pairing == "none") {
        // match every prediction against every sequence file
        Channel.fromPath(prediction).set{ chPred }
        Channel.fromPath(fasta).set{ chSeq }

        findSequences(findscript, chPred, featName)
        extractSequences(extrscript, findSequences.out, chSeq)
        countKmers(countscript, extractSequences.out, kmer)
        sumKmers(sumscript, countKmers.out)
    } else if(pairing == "generic") {
        // naive - match files by name, with different extensions
        Channel.fromFilePairs(prediction + ".{txt,fa}", flat: true).set{ chPairs }

        findAndExtractPair(findscript, extrscript, chPairs, featName)
        countKmers(countscript, findAndExtractPair.out, kmer)
        sumKmers(sumscript, countKmers.out)
    } else if(pairing == "reverse") {
        // match files using the glob file pairer
        Channel.fromPath(prediction).set{ chPred }
        Channel.fromPath(fasta).set{ chSeq }

        ch_pairer(chPred, chSeq).set{ chPairs }
        findAndExtractPair(findscript, extrscript, chPairs, featName)
        countKmers(countscript, findAndExtractPair.out, kmer)
        sumKmers(sumscript, countKmers.out)
    } else {
        println("Unknown pairing mode!")
    }

    emit:
    sumKmers.out
}

workflow {
    countHelixKmers(params.kmer, params.feature, params.pairing, params.pred, params.fasta)
}
