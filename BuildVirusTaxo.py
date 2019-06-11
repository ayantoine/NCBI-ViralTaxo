# coding: utf-8
"""Python3.6"""

import time

sCurrentVersionScript="v1"
iTime1=time.time()
########################################################################
'''
V1-2019/05/28
Get the taxonomy for each viral tax-id from GenBank

python BuildVirusTaxo.py

'''
########################################################################
#CONSTANT
TAXCAT_FILE="categories.dmp"
TAXDUMP_NODES="nodes.dmp"
TAXDUMP_NAMES="names.dmp"

SCIENTIFIC_NAME="scientific name"
VIRAL_TYPE="V"

OUTPUT_FILE="TaxId2Taxo.txt"
########################################################################
#Function 	
def BuildTree(sFilePath):
	dTree={}
	print("Building tree...")
	iCount=0
	for sNewLine in open(sFilePath):
		iCount+=1
		if iCount%100000==0:
			print("\t{}...".format(iCount))
		sLine=sNewLine.strip()
		sLine=sLine.replace("\t","")
		tLine=sLine.split("|")
		iTaxId=int(tLine[0])
		iParentId=int(tLine[1])
		sRank=tLine[2]
		#dTree[iTaxId]={"Parent":iParentId,"Rank":sRank}
		dTree[iTaxId]=iParentId
	return dTree
		
def BuildName(sFilePath):
	dTree={}
	print("Extracting name...")
	iCount=0
	for sNewLine in open(sFilePath):
		iCount+=1
		if iCount%100000==0:
			print("\t{}...".format(iCount))
		sLine=sNewLine.strip()
		sLine=sLine.replace("\t","")
		tLine=sLine.split("|")
		iTaxId=int(tLine[0])
		sName=tLine[1]
		sConfidence=tLine[3]
		try:
			oCrashMe=dTree[iTaxId]
			#if not crash, already in the dict
			#Keep the new only if sConfidence=scientific name
			if sConfidence==SCIENTIFIC_NAME:
				dTree[iTaxId]=sName
		except KeyError:
			dTree[iTaxId]=sName
	return dTree

def GetChain(iId,dNode,dName):
	sName=dName[iId]
	iParent=dNode[iId]
	if iId==1:
		return ""
	return GetChain(iParent,dNode,dName)+sName+";"

def WriteData(dNode,dName,setId,sFile):
	FILE=open(sFile,"w")
	print("Writing output...")
	iCount=0
	for iTaxId in sorted(dNode):
		iCount+=1
		if iCount%100000==0:
			print("\t{}/{}".format(iCount,len(dNode)))
		if iTaxId in setId:
			FILE.write("{}\t{}\n".format(iTaxId,GetChain(iTaxId,dNode,dName)))
	FILE.close()

def GetSetId(sFilePath):
	print("Extracting viral id...")
	setId=set()
	iCount=0
	for sNewLine in open(sFilePath):
		iCount+=1
		if iCount%100000==0:
			print("\t{}...".format(iCount))
		sLine=sNewLine.strip()
		tLine=sLine.split("\t")
		sBiotype=tLine[0]
		iTaxId=int(tLine[2])
		if sBiotype==VIRAL_TYPE:
			setId.add(iTaxId)
	return setId

########################################################################
#MAIN
if __name__ == "__main__":
	#Select Vira TaxId
	setId=GetSetId(TAXCAT_FILE)
	#Build hierarchy
	dNode2Parent=BuildTree(TAXDUMP_NODES)
	#Extract scientific name
	dNode2Name=BuildName(TAXDUMP_NAMES)
	#Write all node
	WriteData(dNode2Parent,dNode2Name,setId,OUTPUT_FILE)
	
########################################################################    
iTime2=time.time()
iDeltaTime=iTime2-iTime1
print("Script done: {}".format(iDeltaTime))
