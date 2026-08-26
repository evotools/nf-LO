

process dataset_genome {
    label "small"

    input:
    val accession
    
    output:
    path "${accession}.fasta"

    script:
    """
    datasets download genome accession ${accession} --include genome && \\
        7za x ncbi_dataset.zip && \\
        cat ncbi_dataset/data/${accession}/*.fna > ${accession}.fasta && rm -rf ncbi_dataset*
    """

    stub:
    """
    touch ${accession}.fasta
    """
}
