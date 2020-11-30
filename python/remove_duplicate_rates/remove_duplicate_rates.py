#!/usr/bin/python3
import xlrd
import sys

workBook=xlrd.open_workbook(sys.argv[1])

keySheet=workBook.sheet_by_name("Key")
valueSheet=workBook.sheet_by_name("Value")

listOfKeys=[";".join(keySheet.row_values(i)).replace(" ","").upper() for i in range(1, keySheet.nrows)]
listofValues=[float("0"+str(valueSheet.cell_value(i,0))) for i in range(1,valueSheet.nrows)]
uniqKeys=set(listOfKeys)

for uniqKey in uniqKeys:
    maxValue=0;
    for i,x in enumerate(listOfKeys):
        if x == uniqKey:
            maxValue=max(maxValue, listofValues[i])
    if maxValue != 0:
        print(uniqKey+";"+str(maxValue))
    else:
        print(uniqKey+";Please Check the Value Manually")

