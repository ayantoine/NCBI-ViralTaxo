#! /bin/bash

set -e #if a command crash, the script interrupt immediatly

CatTarget="taxcat"
DmpTarget="taxdump"
TargetArray=(${CatTarget} ${DmpTarget})
DmpFile=("nodes.dmp" "names.dmp")
CatFile="categories.dmp"

NeedUpdate=false

for Target in "${TargetArray[@]}"; do
	#Download checksum file
	curl ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/${Target}.tar.gz.md5 --output ${Target}.md5
	
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
		fi
	else
		echo "No past version of "${Target}
		NeedUpdate=true
	fi
done

if [ "$NeedUpdate" = true ] ; then
	for Target in "${TargetArray[@]}"; do
		#Download
		curl ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/${Target}.tar.gz --output ${Target}.tar.gz
		
		#Checksum verification
		echo "------CheckSum verification------"
		CheckRef=`cat ${Target}.md5`
		echo "CheckRef $CheckRef"
		md5sum ${Target}.tar.gz > ${Target}.current.md5
		CheckSum=`cat ${Target}.current.md5`
		echo "CheckSum $CheckSum"
		echo "------/CheckSum verification------"
		
		if test "$CheckRef" != "$CheckSum" ; then
			rm ${Target}.tar.gz
			echo "Unable to dowload accurate file for "${Target}
			exit 1
		fi
		
		#extract file
		if test "${CatTarget}" = "$Target" ; then
			tar -xf ${Target}.tar.gz
		else
			#extract specific file
			for File in "${DmpFile[@]}" ; do
				tar -xf ${Target}.tar.gz ${File}
			done
		fi
		
		#Store new checksum, then remove file
		mv ${Target}.current.md5 ${Target}.past.md5
		rm ${Target}.tar.gz
		rm ${Target}.md5
	done
else
	echo "Nothing to update"
	for Target in "${TargetArray[@]}"; do
		rm ${Target}.md5
	done
	touch Taxo.accurate
fi
