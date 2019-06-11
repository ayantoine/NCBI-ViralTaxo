#! src/bash
#DEPRECATED -> now include in BuildVirusTaxo.sh

SDIR="/home/antoine/Documents/Python/TINAP"
TargetTag="vrl"

ListFile=$(curl -l ftp://ftp.ncbi.nlm.nih.gov/genbank/)
ListTarget=$(echo "${ListFile}" | grep "$TargetTag")
echo "$ListTarget" > ListTarget.txt

python $SDIR/RewriteListTarget.py ListTarget.txt

bash DownloadListTarget.sh
rm DownloadListTarget.sh

gunzip *.gz

python $SDIR/ExtractAccId2Definition.py

