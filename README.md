# NCBI-ViralTaxo
Retrieve taxonomy and Definition for each viral AccessionID.Version from NCBI

The workflow work step by step and compare to last file version in order to minimize download and computation

# Usage
bash PATH/TO/BuildViralTaxo.sh PATH/TO/

PATH/TO: Path to the directory that contains all scripts. Can (must?) be different to the directory where to store the taxonomy

# Output
nucl_gb.accession2taxo.tsv: tsv file, col1 Prot AccId, col2 organism, col3 taxonomy, col4 NCBI definition if avalaible (default "."), col5 ". .", col6 "."

prot.accession2taxo.tsv: tsv file, col1 Prot AccId, col2 organism, col3 taxonomy, col4 NCBI definition if avalaible (default "."), col5 ". .", col6 "." 

TaxId2Taxo.tsv: tsv file, col1 TaxId, col2 associated taxonomy

taxcat.past.md5: the md5 checksum of used taxcat

taxdump.past.md5: the md5 checksum of used taxdump

nucl_gb.accession2taxid.past.md5: the md5 checksum of used nucl_gb.accession2taxid.past.md5

prot.accession2taxid.past.md5: the md5 checksum of used prot.accession2taxid.past.md5

# Workflow
Step1 - download md5 value for taxcat and taxdump

Step2 - compare with past value if avalaible. If the same, go to step6

Step3 - download taxcat and taxdump

Step4 - build TaxId2Taxo.tsv

Step5 - compare to old TaxId2Taxo.tsv if avalaible. If not the same, force N and P update

Step6 - download md5 value for N and P

Step7 - compare witn past value if avalaible. If the same, end without change

Step8 - download FlatFile and produce AccId2Def.tsv

Step9 - download N and P

Step10 - Select only Viral AccId and produce N and P 2taxo.tsv

