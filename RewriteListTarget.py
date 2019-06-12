# coding: utf-8
"""Python3.6"""
# compatibility: python2.7, python2.6

import sys
import time

sCurrentVersionScript="v3"
iTime1=time.time()
########################################################################
'''
V2-2019/06/12
Add recovery on error for FlatTax downloading

V2-2019/06/12
Make code compatible for py2.6 (only version present on Agap)
V1-2019/06/07
Create a bash file to download all viral file.seq from genbank

python RewriteListTarget.py BASEFILE
BASEFILE: file that contains all file names to download from FTP
'''
########################################################################
#CONSTANT
GBK_FTP="ftp://ftp.ncbi.nlm.nih.gov/genbank/"

########################################################################
#MAIN
if __name__ == "__main__":
	FILE=open("DownloadListTarget.sh","w")
	FILE.write("#! /bin/bash\n")
	FILE.write("set -e\n") #if a command crash, the script interrupt immediatly
	for sNewLine in open(sys.argv[1]):
		sLine=sNewLine.strip()
		# sModifiedLine="echo \"Downloading {}...\"\ncurl {}{} --output {}\n".format(sLine,GBK_FTP,sLine,sLine)
		sModifiedLine="if [ ! -f "+sLine+" ] ; then \n"
		sModifiedLine+="\techo \"Downloading "+sLine+"...\"\n"
		sModifiedLine+="\tcurl "+GBK_FTP+sLine+" --output {}\n"
		sModifiedLine+="else\n"
		sModifiedLine+="\techo \""+sLine+" already present, no download\"\n"
		sModifiedLine+="fi\n"
		FILE.write(sModifiedLine)
	FILE.close()
########################################################################    
iTime2=time.time()
iDeltaTime=iTime2-iTime1
print("Script done: "+str(iDeltaTime))
