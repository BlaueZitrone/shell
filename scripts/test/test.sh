dir=/ext/schenker/support/allen/test
echo -e "${dir}:\t$(ls | wc -l) file(s)"
for agreement in $(ls ${dir}/ | cut -d\. -f1 | sort | uniq -c | sort -nr | awk '{print $NF}')
do
    echo "**********************************************************************************************************************"
    echo -e "${agreement}:\t$(ls ${dir}/ | grep -c ${agreement}) file(s)";
    echo "**********************************************************************************************************************"
    echo "     oldest file:             $(ls -lt ${dir}/ | grep SCFRW4IRXM_DHL_outbound | tail -1 | gsed 's#-rw-rw----   1 xib      xib##')";
    echo "most recent file:             $(ls -lt ${dir}/ | grep SCFRW4IRXM_DHL_outbound | head -1 | gsed 's#-rw-rw----   1 xib      xib##')";
    echo -e "**********************************************************************************************************************\n"
done
