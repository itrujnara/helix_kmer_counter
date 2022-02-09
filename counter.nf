#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

params.outdir = "results/"

// include { ch_pairer } from "./channel_pairer.nf"
include { pairer } from "./pairer.nf"
include { findSequences; extractSequences; findAndExtractPair; countKmers; sumKmers } from "./processes.nf" addParams(outdir: "${params.outdir}")

params.kmer = 3
params.feature = "s"
params.pairing = "none"
params.fasta = "data/sequence.fa"
params.pred = "data/prediction.txt"

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
