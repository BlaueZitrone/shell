#!/usr/bin/python3
import xlrd
import sys

workBook=xlrd.open_workbook(sys.argv[1])

keySheet=workBook.sheet_by_name("Key")
valueSheet=workBook.sheet_by_name("Value")

listOfKeys=[";".join(keySheet.row_values(i)).replace(" ","").upper() for i in range(1, keySheet.nrows)]
listofValues=[float("0"+str(valueSheet.cell_value(i,0))) for i in range(1,valueSheet.nrows)]
uniqKeys=set()
duplicateKeys=set()
for element in listOfKeys:
    if element in uniqKeys:
        duplicateKeys.add(element)
    else:
        uniqKeys.add(element)

for duplicateKey in duplicateKeys:
    print(duplicateKey)
    for i,x in enumerate(listOfKeys):
        if x == duplicateKey:
            print("    Row: "+str(i+2)+" Value: "+str(listofValues[i]))

