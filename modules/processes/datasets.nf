

process get_dataset {
    label "small"

    output:
    path "datasets"

    script:
    """
    if [[ "\$OSTYPE" == "linux-gnu"* ]]; then
        curl -o datasets 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/LATEST/linux-amd64/datasets' 
    elif [[ "\$OSTYPE" == "darwin"* ]]; then
            # Mac OSX
        curl -o datasets 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/LATEST/mac/datasets' 
    elif [[ "\$OSTYPE" == "cygwin" ]]; then
        curl -o datasets 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/LATEST/linux-amd64/datasets' 
    fi
    chmod a+x datasets
    """

}

process dataset_genome {
    label "small"

    input:
    val genome
    path datasets
    
    output:
    path "${genome}.fasta"

    script:
    """
    ./datasets download genome accession ${genome}
    unzip ncbi_dataset.zip
    cat ncbi_dataset/data/${genome}/*.fna > ${genome}.fasta 
    rm -rf ncbi_dataset*
    """
}
