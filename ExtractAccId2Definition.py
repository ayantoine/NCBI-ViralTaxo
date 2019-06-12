# coding: utf-8
"""Python3.6"""
# compatibility: python2.7, python2.6

import sys
import os
import time

sCurrentVersionScript="v2"
iTime1=time.time()
########################################################################
'''
V2-2019/06/12
Make code compatible for py2.6 (only version present on Agap)

V1-2019/06/07
Parse all viral flatfile of Genbank in order to get Definition field

python ExtractAccId2Definition.py
'''
########################################################################
#CONSTANT
TAG=".seq"
DEFINITION="DEFINITION"
ACCESSION="ACCESSION"
VERSION="VERSION"
OUTPUT="AccId2Def.tsv"
########################################################################
#MAIN
if __name__ == "__main__":
	tItems=os.listdir("./")
	FILE=open(OUTPUT,"w")
	for sFile in tItems:
		if TAG in sFile:
			print("Working on "+sFile)
			bDef=False
			sDef=""
			sAcc=""
			for sNewLine in open(sFile):
				sLine=sNewLine.strip()
				if DEFINITION in sLine:
					bDef=True
					sLine=sLine.replace(DEFINITION+"  ","")
				elif ACCESSION in sLine:
					bDef=False
				elif VERSION in sLine:
					sAcc=sLine.split(" ")[-1]
					FILE.write(sAcc+"\t"+sDef+"\n")
					bDef=False
					sDef=""
					sAcc=""
				if bDef:
					if sDef!="":
						sDef+=" "
					sDef+=sLine
	FILE.close()
########################################################################    
iTime2=time.time()
iDeltaTime=iTime2-iTime1
print("Script done: "+str(iDeltaTime))
				
			





