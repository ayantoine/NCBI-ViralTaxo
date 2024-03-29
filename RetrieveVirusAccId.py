# coding: utf-8
"""Python3.6"""
# compatibility: python2.7, python2.6

import sys
from optparse import OptionParser
import time

sCurrentVersionScript="v2"
iTime1=time.time()
########################################################################
'''
V2-2019/06/12
Make code compatible for py2.6 (only version present on Agap)

V1-2019/05/28
Get the taxonomy for each viral tax-id from GenBank

python BuildVirusTaxo.py -t

'''
########################################################################
#Options
parser = OptionParser()
parser.add_option("-t","--typeData", dest="typeData")

(options, args) = parser.parse_args()

sTypeData=options.typeData
if not sTypeData:
    sys.exit("Error : no typeData -t defined, process broken")
else:
	try:
		sTypeData=sTypeData.upper()
	except TypeError:
		sys.exit("Error : typeData -t must be a character (n or p), process broken")

########################################################################
#CONSTANT
TYPE_NUC="N"
TYPE_PRO="P"

NUC_BASEFILE="nucl_gb.accession2taxid"
PRO_BASEFILE="prot.accession2taxid"
TAX_BASEFILE="TaxId2Taxo.tsv"
DEF_BASEFILE="AccId2Def.tsv"

NUC_LASTFILE="nucl_gb.accession2taxo."+time.strftime("%Y-%m-%d")+".tsv"
PRO_LASTFILE="prot.accession2taxo."+time.strftime("%Y-%m-%d")+".tsv"

BASEFILE={TYPE_NUC:NUC_BASEFILE,TYPE_PRO:PRO_BASEFILE}
LASTFILE={TYPE_NUC:NUC_LASTFILE,TYPE_PRO:PRO_LASTFILE}

BOOL_DEBUG=False
DEBUG_TAXID=1742422
DEBUG_ACCID="ALL74044.1"
########################################################################
#Function 	
def ReadTaxFile(sFile):
	dData={}
	bFirstDebug=BOOL_DEBUG
	print("Read Tax file...")
	for sNewLine in open(sFile):
		sLine=sNewLine.strip()
		tLine=sLine.split("\t")
		dData[int(tLine[0])]=tLine[1]
		if bFirstDebug:
			print("First line :")
			print(sNewLine)
			bFirstDebug=False
		if BOOL_DEBUG and int(tLine[0])==DEBUG_TAXID:
			print(sNewLine)
	return dData
	
def ReadAcc2DefFile(sFile):
	dData={}
	bFirstDebug=BOOL_DEBUG
	print("Read Acc2Def file...")
	for sNewLine in open(sFile):
		sLine=sNewLine.strip()
		tLine=sLine.split("\t")
		dData[tLine[0]]=tLine[1]
		if bFirstDebug:
			print("First line :")
			print(sNewLine)
			bFirstDebug=False
		if BOOL_DEBUG and tLine[0]==DEBUG_ACCID:
			print(sNewLine)
	return dData

def WriteLastFile(dData,dDef,sTag):
	bFirstDebug=BOOL_DEBUG
	print("Read Access file and write output...")
	FILE=open(LASTFILE[sTag],"w")
	bHeader=True
	iCount=0
	for sNewLine in open(BASEFILE[sTag]):
		iCount+=1
		if iCount%100000==0:
			print("\t"+str(iCount)+"...")
		if bHeader:
			bHeader=False
			continue
		sLine=sNewLine.strip()
		tLine=sLine.split()
		sAccession=tLine[1]
		iTaxId=int(tLine[2])
		try:
			sDef=dDef[sAccession]
		except KeyError:
			#No def
			sDef="."
		try:
			tData=dData[iTaxId][:-1].split(";")
			sToWriteLine=sAccession+"\t"+tData[-1]+"\t"+";".join(tData[:-1])+"\t"+sDef+"\t. .\t.\n"
			# sToWriteLine="{}\t{}\t{}\t{}\t. .\t.\n".format(sAccession,tData[-1],";".join(tData[:-1]),sDef)
			if bFirstDebug:
				print("First line :")
				print(sToWriteLine)
				bFirstDebug=False
			FILE.write(sToWriteLine)
		except KeyError:
			#Not a viral taxid
			if BOOL_DEBUG and iTaxId==DEBUG_TAXID:
				print("TaxId "+str(iTaxId)+" for accId "+sAccession+" is not a viral taxid")
			continue
	FILE.close()

########################################################################
#MAIN
if __name__ == "__main__":
	if sTypeData not in [TYPE_NUC,TYPE_PRO]:
		sys.exit("Error : typeData -t must be N or P, process broken")
	#Load Taxfile
	dTaxId2Taxo=ReadTaxFile(TAX_BASEFILE)
	#Load Acc2Def
	dAccId2Def=ReadAcc2DefFile(DEF_BASEFILE)
	#Write Lastfile
	WriteLastFile(dTaxId2Taxo,dAccId2Def,sTypeData)
	
########################################################################    
iTime2=time.time()
iDeltaTime=iTime2-iTime1
print("Script done: "+str(iDeltaTime))




















