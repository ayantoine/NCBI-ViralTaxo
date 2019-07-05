#! /bin/bash

set -e #if a command crash, the script interrupt immediatly

FTPlineage="ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/new_taxdump/"
TarLineage="new_taxdump"
SubFileLineage="fullnamelineage.dmp"

FTPaccId="ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid"
NTarget="nucl_gb.accession2taxid"
PTarget="prot.accession2taxid"
TargetArray=(${NTarget} ${PTarget})

NeedUpdate=false

##Lineage part
#Download checksum file
echo ${FTPlineage}/${TarLineage}.tar.gz.md5 --output ${TarLineage}.md5
curl ${FTPlineage}/${TarLineage}.tar.gz.md5 --output ${TarLineage}.md5

#Load checksum
CheckRef=`cat ${TarLineage}.md5`

#Check if update is needed
if [ -f ${TarLineage}.past.md5 ] ; then
	CheckSum=`cat ${TarLineage}.past.md5`
	if test "$CheckRef" != "$CheckSum" ; then
		echo "Past version of "${TarLineage}" was not accurate"
		echo "CheckRef $CheckRef"
		echo "CheckSum $CheckSum"
		rm ${TarLineage}.past.md5
		NeedUpdate=true
	else
		echo "Past version of "${TarLineage}" was accurate"
	fi
else
	echo "No past version of "${TarLineage}
	NeedUpdate=true
fi

if [ "$NeedUpdate" = true ] ; then
	#Download
	echo ${FTPlineage}/${TarLineage}.tar.gz --output ${TarLineage}.tar.gz
	curl ${FTPlineage}/${TarLineage}.tar.gz --output ${TarLineage}.tar.gz
	
	#Checksum verification
	echo "------CheckSum verification------"
	CheckRef=`cat ${TarLineage}.md5`
	echo "CheckRef $CheckRef"
	md5sum ${TarLineage}.tar.gz > ${TarLineage}.current.md5
	CheckSum=`cat ${TarLineage}.current.md5`
	echo "CheckSum $CheckSum"
	echo "------/CheckSum verification------"
	
	if test "$CheckRef" != "$CheckSum" ; then
		rm ${TarLineage}.tar.gz
		echo "Unable to dowload accurate file for "${TarLineage}
		exit 1
	fi
	
	#extract specific file
	tar -xf ${TarLineage}.tar.gz ${SubFileLineage}
	
	#Store new checksum, then remove file
	mv ${TarLineage}.current.md5 ${TarLineage}.past.md5
	rm ${TarLineage}.tar.gz
	rm ${TarLineage}.md5
else
	rm ${TarLineage}.md5
fi

for Target in "${TargetArray[@]}"; do
	NeedUpdate=false

	#Download checksum file
	curl ${FTPaccId}/${Target}.gz.md5 --output ${Target}.md5
	
	#Load checksum
	CheckRef=`cat ${Target}.md5`
	
	#Check if upadte is needed
	if [ -f ${Target}.past.md5 ] ; then
		CheckSum=`cat ${Target}.past.md5`
		if test "$CheckRef" != "$CheckSum" ; then
			echo "Past version of "${Target}" was not accurate"
			echo "CheckRef $CheckRef"
			echo "CheckSum $CheckSum"
			rm ${Target}.past.md5
			NeedUpdate=true
		else
			echo "Past version of "${Target}" was accurate"
			rm ${Target}.md5
		fi
	else
		echo "No past version of "${Target}
		NeedUpdate=true
	fi
	
	if [ "$NeedUpdate" = true ] ; then
		#Download
		curl ${FTPaccId}/${Target}.gz --output ${Target}.gz
		
		#Checksum verification
		echo "------CheckSum verification------"
		CheckRef=`cat ${Target}.md5`
		echo "CheckRef $CheckRef"
		md5sum ${Target}.gz > ${Target}.current.md5
		CheckSum=`cat ${Target}.current.md5`
		echo "CheckSum $CheckSum"
		echo "------/CheckSum verification------"
		
		if test "$CheckRef" != "$CheckSum" ; then
			rm ${Target}.gz
			echo "Unable to dowload accurate file for "${Target}
			exit 1
		fi
		
		#extract file
		gunzip ${Target}.gz
		
		#Store new checksum, then remove file
		mv ${Target}.current.md5 ${Target}.past.md5
		rm ${Target}.md5
	fi	
done
