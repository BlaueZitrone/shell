#!/usr/bin/python3
import xlrd
import sys

workBook=xlrd.open_workbook(sys.argv[1])

mainKeySheet=workBook.sheet_by_name("M_Key")
optionalKeySheet=workBook.sheet_by_name("O_Key")
valueSheet=workBook.sheet_by_name("Value")

MTitle=";".join(mainKeySheet.row_values(0)).replace(" ","").upper()
OTitle=";".join(optionalKeySheet.row_values(0)).replace(" ","").upper()
listOfMKeys=[";".join(mainKeySheet.row_values(i)).replace(" ","").upper() for i in range(1, mainKeySheet.nrows)]
listOfOKeys=[";".join(optionalKeySheet.row_values(i)).replace(" ","").upper() for i in range(1, optionalKeySheet.nrows)]
listofValues=[float("0"+str(valueSheet.cell_value(i,0))) for i in range(1,valueSheet.nrows)]
allMKeys=set()
uniqMKeys=set()
duplicateMKeys=set()
#filter out the duplicate keys
for element in listOfMKeys:
    if element in allMKeys:
        duplicateMKeys.add(element)
    else:
        allMKeys.add(element)

uniqMKeys = allMKeys - duplicateMKeys

print("######## Uniq Record ########")
print("    Row;Value;"+MTitle)
for uniqMKey in uniqMKeys:
    for i,x in enumerate(listOfMKeys):
        if x == uniqMKey:
            print("    "+str(i+2)+";"+str(listofValues[i])+";"+str(listOfMKeys[i]))

print("######## Duplicate Record ########")
for duplicateMKey in duplicateMKeys:
    print(MTitle+" : "+duplicateMKey)
    #count the amount of different values
    values=set()
    oKeys=set()
    for i,x in enumerate(listOfMKeys):
        if x == duplicateMKey:
            values.add(listofValues[i])
            oKeys.add(listOfOKeys[i])

    print("    group by value:")
    print("        Row;Value;"+OTitle+"\n")
    for vi,vx in enumerate(values):
        for oi,ox in enumerate(oKeys):
            for i,x in enumerate(listOfMKeys):
                if x == duplicateMKey and vx == listofValues[i] and ox == listOfOKeys[i]:
                    print("        "+str(i+2)+";"+str(listofValues[i])+";"+str(listOfOKeys[i]))
        print()

    print("    group by optional key:")
    print("        Row;"+OTitle+";Value\n")
    for oi,ox in enumerate(oKeys):
        for vi,vx in enumerate(values):
            for i,x in enumerate(listOfMKeys):
                if x == duplicateMKey and vx == listofValues[i] and ox == listOfOKeys[i]:
                    print("        "+str(i+2)+";"+str(listOfOKeys[i])+";"+str(listofValues[i]))
        print()

