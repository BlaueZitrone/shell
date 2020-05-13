
import xlrd

workbook=xlrd.open_workbook("testdata.xls")
#print(workbook.sheet_names())
worksheet=workbook.sheet_by_name("testdata")
print(worksheet.name)
nrows=worksheet.nrows
#print(nrows)
for key_ncol in [3,7,10,13,15]:
    print(worksheet.col_values(key_ncol), end="\n")