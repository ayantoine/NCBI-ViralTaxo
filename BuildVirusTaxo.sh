#! /bin/bash

# bash PATH/TO/BuildVirusTaxo.sh PATH/TO/

set -e #if a command crash, the script interrupt immediatly

SDIR=$1
GENBANK_FTP="ftp://ftp.ncbi.nlm.nih.gov/genbank/"
NTarget="nucl_gb.accession2taxid"
PTarget="prot.accession2taxid"
TargetArray=(${NTarget} ${PTarget})
DoUpdate=false
FlatFileTag="vrl"

#Dwld Tax files
bash $SDIR/DownloadTaxonomy.sh

if [ ! -f Taxo.accurate ] ; then
	#Tax file have modification since last time
	#Store the old version
	if [ -f TaxId2Taxo.tsv ] ; then
		scp TaxId2Taxo.tsv TaxId2Taxo.past.tsv
		#Run a new version
		python $SDIR/BuildVirusTaxo.py
		#Check diff
		IsDiff=`diff TaxId2Taxo.past.tsv TaxId2Taxo.tsv`
		if [ "$IsDiff" = "" ] ; then
			echo "Same TaxId2Taxo file product, if AccId are accurate, no update needed"
		else
			echo "New TaxId2Taxo file product, update AccId needed"
			DoUpdate=true
		fi	
		#In all case, remove TaxId2Taxo.past
		rm TaxId2Taxo.past.tsv
	else
		python $SDIR/BuildVirusTaxo.py
		DoUpdate=true
	fi
	rm *.dmp
else
	rm Taxo.accurate
fi

#If an update is needed, force the suppression of Target's past.md5
if [ "$DoUpdate" = true ] ; then
	for Target in "${TargetArray[@]}"; do
		if [ -f ${Target}.past.md5 ] ; then 
			rm ${Target}.past.md5
		fi
	done
fi

#Dwld Target files
bash $SDIR/DownloadAccession.sh

#If an update on AccId is needed, rebuild AccId2Def.tsv
DoUpdate=false
for Target in "${TargetArray[@]}"; do
	if [ ! -f ${Target}.accurate ] ; then
		DoUpdate=true
	fi
done
if [ "$DoUpdate" = true ] ; then
	#Retrieve all Viral Genbank file
	ListFile=$(curl -l ${GENBANK_FTP})
	ListTarget=$(echo "${ListFile}" | grep "$FlatFileTag")
	echo "$ListTarget" > ListTarget.txt
	#Plan download
	python $SDIR/RewriteListTarget.py ListTarget.txt
	rm ListTarget.txt
	#download
	bash DownloadListTarget.sh
	rm DownloadListTarget.sh
	#unzip
	gunzip *.gz
	#process -> AccId2Def.tsv
	python $SDIR/ExtractAccId2Definition.py
rm *.seq
fi

for Target in "${TargetArray[@]}"; do
	if [ ! -f ${Target}.accurate ] ; then
		python $SDIR/RetrieveVirusAccId.py -t ${Target:0:1}
		rm ${Target}
	fi
	if [ -f ${Target}.accurate ] ; then
		rm ${Target}.accurate
	fi
done

#Rm temp file created by ExtractAccId2Definition.py
if [ -f "AccId2Def.tsv" ] ; then
	rm AccId2Def.tsv
fi

#sort file for easy join in TINAP-workflow
sort -k 1,1 nucl_gb.accession2taxo.tsv > nucl_gb.accession2taxo.sort.tsv
mv nucl_gb.accession2taxo.sort.tsv nucl_gb.accession2taxo.tsv
sort -k 1,1 prot.accession2taxo.tsv > prot.accession2taxo.sort.tsv
mv prot.accession2taxo.sort.tsv prot.accession2taxo.tsv

