#!/bin/bash
begin='http://'
end='.s3.amazonaws.com'
folder_list='list'
sort_date='_sorted_date'
sort_size='_sorted_size'
#loop through the list of bucket names
for bucket_name in $(cat aws_list.txt)
do
	url=$begin$bucket_name$end
	mkdir $bucket_name
	cd $bucket_name
	aws s3 ls s3://$bucket_name --no-sign-request --human-readable --summarize > folders.txt
	grep -oP '(?<=PRE ).*' folders.txt > only_folders.txt
	sort -b -k 1,1 -k 2,2 -k 4,4 -k 3,3 folders.txt>folders$sort_date.txt
	sort -b -k 4,4 -k 3,3 -k 1,1 -k 2,2 folders.txt>folders$sort_size.txt
	grep 'logo' folders.txt > logo_folders.txt
	mkdir lsFiles
	cd lsFiles
	for folder in $(cat ../only_folders.txt)
	do
		folder_name=${folder::-1}
		echo $folder
		aws s3 ls s3://$bucket_name/$folder --no-sign-request --human-readable --summarize --recursive > $folder_name.txt
	done
	for lsfile in *
	do
		echo $lsfile
		num_of_files=$(grep -oP '(?<=Total Objects: ).*' $lsfile)
		size_of_files=$(grep -oP '(?<=Total Size: ).*(?=\ )' $lsfile)
		units=$(grep -oP "(?<=Total Size: $size_of_files) ".* $lsfile)
		#if (("$num_of_files"==0))
		#then
		#	continue
		#fi
		echo $lsfile>>sizes.txt
		echo $num_of_files>>sizes.txt
		echo $size_of_files>>sizes.txt
		echo $units>>sizes.txt
		#this part would be much easier in python
		
		#if (("$units"=='bytes'))
		#then
		#	new_size_of_files=$("$size_of_files / 1073741824" | bc -q)
		#fi
		#if (("$units"=='KiB'))
		#then
		#	$new_size_of_files=$((float_eval "$size_of_files/1048576"))
		#fi
		#if (("$units"=='MiB'))
		#then
		#	$new_size_of_files=$((float_eval($size_of_files/1024)))
		#fi
		#if (("$units"=='TiB'))
		#then
		#	$new_size_of_files=$((float_eval($size_of_files*1024)))
		#fi
		#$total_num_of_files+=$(($total_num_of_files+$new_num_of_files))
		#$total_size_of_files+=$(($total_size_of_files+$size_of_files))
		
		sort -b -k 1,1 -k 2,2 -k 4,4 -k 3,3 $lsfile>$lsfile$sort_date.txt
		sort -b -k 4,4 -k 3,3 -k 1,1 -k 2,2 $lsfile>$lsfile$sort_size.txt
		grep 'logo' $lsfile >> logo_$bucket_name.txt
	done
	#echo "url = $url\n total_num_of_files = $total_num_of_files\n total_size_of_files = $total_size_of_files" > auto_short_$bucket_name.txt
	cd ../
	cd ../
done
