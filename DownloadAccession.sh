#! src/bash

NTarget="nucl_gb.accession2taxid"
PTarget="prot.accession2taxid"
TargetArray=(${NTarget} ${PTarget})

for Target in "${TargetArray[@]}"; do
	NeedUpdate=false

	#Download checksum file
	curl ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/${Target}.gz.md5 --output ${Target}.md5
	#curlExitcode=`echo "$?"`
	#echo "$curlExitcode"
	
	#If curl command fail, exit
	#if [ ! 0 -eq $curlExitcode ] ; then
		##echo "0 = $curlExitcode"
		#exit 1
	#else
		#echo "0 = $curlExitcode"
	#fi
	
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
		curl ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/${Target}.gz --output ${Target}.gz
		#curlExitcode=`echo "$?"`
		#echo "$curlExitcode"
	
		#If curl command fail, exit
		#if [ ! 0 -eq $curlExitcode ] ; then
			##echo "0 = $curlExitcode"
			#exit 1
		#else
			#echo "0 = $curlExitcode"
		#fi
		
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
	else
		touch ${Target}.accurate
	fi
	
done
