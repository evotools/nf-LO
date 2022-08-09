

process dataset_genome {
    label "small"

    input:
    val genome
    
    output:
    path "${genome}.fasta"

    stub:
    """
    touch ${genome}.fasta
    """

    script:
    """
    datasets download genome accession --exclude-rna --exclude-protein --exclude-protein --exclude-gff3 --exclude-genomic-cds ${genome} &&
        7za x ncbi_dataset.zip && \
        cat ncbi_dataset/data/${genome}/*.fna > ${genome}.fasta && rm -rf ncbi_dataset*
    """
}
