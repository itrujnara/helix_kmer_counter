#!/usr/bin/env nextflow

nextflow.enable.dsl = 2


params.help = false


// this prints the help in case you use --help parameter in the command line and it stops the pipeline
if (params.help) {
    log.info "HERE THE HELP WILL BE WRITTEN LIKE THIS :"
	log.info "This pipeline computes ..... "
	log.info "mention that there is the for the pred file and the fasta file to have the same sequences id in the same order"
	log.info "explain the use of each flag and espacially the behaviour of --pairing  like the necessity of files to be .txt or .fa"
	log.info "and the fact that using the standard behaviour the fasta flag becomes useless because both input types have to be inside the same glob pattern specificity    TEMPORARY MAYBE FIXABLE"
}



// params section

params.kmer = 3
params.feature = "s"
params.pairing = "standard"
params.fasta = "data/sequence.fa"
params.pred = "data/prediction.txt"
params.outdir = "results/"


// include section

include { ch_pairer } from "${params.PIPES}channel_pairer.nf"
include { pairer } from "${params.PIPES}input_files_pairer.nf"

/*
process findSequences {
    input:
    path pyscript
    path pred_file
    val feature_id
    
    output:
    path "seq_ranges_*.txt", emit: ranges
	stdout emit: standardout                    // debug porpouses    
    script:
    suffix = "seq_ranges_${pred_file.getFileName()}".split('\\.')[0] + ".txt"
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
    //path "seqs_*.txt"
	stdout emit: standardout                    // debug porpouses
    
    script:
    suffix = "${ranges.getFileName()}".split('\\.')[0] + "__" + "${fasta.getFileName()}".split('\\.')[0] + ".txt"
    """
	python3 ${pyscript} ${ranges} ${fasta} ${suffix}
    """
}
*/

process findAndExtractSeq {
    
	input:
    path findscript
    path extrscript
    tuple val(matcher), path(predFile), path(fastaFile)
    val featureID

    output:
    path "seqs_pair_*.fa", emit: sub_seqs
	stdout emit: standardout

    script:
	suffix = "seqs_${matcher}.fa"
	prefix = "${predFile}".split("${matcher}")[0].split('\\.')[0]						// used later on at the final step for the output name
    """
    python3 ${findscript} ${predFile} ${suffix} ${featureID}
    python3 ${extrscript} ${suffix} ${fastaFile} "seqs_pair_${matcher}.fa"
	echo ${prefix}
    """
}


process countKmers {
    input:
    path pyscript
    path seqs
    val kmer

    output:
    path "seq_kmers_*.txt", emit: kmers_counts
    stdout emit: standardout                    // debug porpouses

    script:
	suffix = "${seqs.getFileName()}".split("seqs_pair_")[1].split('\\.')[0] + ".txt"
    """
    python3 ${pyscript} ${seqs} "seq_kmers_${suffix}" ${kmer}
    """
}

process sumKmers {
    publishDir params.outdir, mode: "move", overwrite: false

    input:
    path pyscript
    path kmers
	val suffix

    output:
    path "${final_name}", emit: tot_kemers
    stdout emit: standardout

    script:
	final_name =  "total_kmers_" + "${suffix}_".replaceAll("\n", "") + "${kmers}".split("seq_kmers_")[1]
    """
    echo ${suffix}
    echo ${kmers}
    python3 ${pyscript} ${kmers} ${final_name}
    """
}

workflow countHelixKmers {
    take:
    kmer
    featName
    prediction
    fasta

    main:
    // script finder
    findscript = params.SCRIPTS + "find_seqs.py"
    extrscript = params.SCRIPTS + "extract_seqs.py"
    countscript = params.SCRIPTS + "kmer_count.py"
    sumscript = params.SCRIPTS + "sum_kmers.py"

    // channel definitions
    pairedInputs = ""
    if(params.pairing == "standard"){
		pairedInputs = Channel.fromFilePairs( prediction + ".{txt,fa}").map{ [it[0], it[1][1], it[1][0]] }	// not to have list of lists and fa comes before txt
    } else {
		pairer(prediction, fasta)
        pairedInputs = pairer.out.right_pairs
    }
	findAndExtractSeq(findscript, extrscript, pairedInputs, featName)
    countKmers(countscript, findAndExtractSeq.out.sub_seqs, kmer)
	sumKmers(sumscript, countKmers.out.kmers_counts, findAndExtractSeq.out.standardout)
    
	emit:
    final_out = sumKmers.out.tot_kemers
	stdout = sumKmers.out.standardout // for debug porpouses
}

workflow {
    countHelixKmers(params.kmer, params.feature, params.pred, params.fasta)
	countHelixKmers.out.final_out.view()
	countHelixKmers.out.stdout.view()		// for debug porpouses
}