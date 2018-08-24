OLDIFS=$IFS;
IFS=$'\n';
#echo > tmp;
for ao_line in $(cat ao_standard_alias.csv)
do
	ao_key="$(echo ${ao_line} | awk -F',' '{print $1}')";
	echo "ao_key = $ao_key"
	ao_value="$(echo ${ao_line} | awk -F',' '{print $2}')";
	echo "ao_value = $ao_value"
	echo alias "${ao_key}=\"${ao_value}\""
	#echo "alias ${ao_key}=\"${ao_value}\"" >> tmp;
	#. tmp;
	#rm tmp;
done
IFS=$OLDIFS