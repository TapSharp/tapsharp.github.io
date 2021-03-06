#!/bin/bash

script_dir=$(dirname $0)
cur=$(pwd)

cd "$script_dir"
if [ $# -eq 0 ]; then
  echo "Usage: $0 <command>" >&2
  exit 1
fi

if [ "$1" == "add" ]; then
	if [ "$#" -ne 2 ]; then
	  echo "Usage: $0 add <package> <deb file>" >&2
	  exit 1
	fi
	echo "Adding new package...";

	cp "$2" "$script_dir/debs/"

elif [ "$1" == "update" ]; then
	echo "Updating packaging...";
else
	echo "Usage: $0 <command>" >&2
	exit 1
fi

rm Packages.bz2
rm Packages

for deb in debs/*.deb
do
	echo "Processing $deb...";
  dpkg-deb -f "$deb" >> Packages
	md5 -r "$deb" | echo "MD5sum: $(awk '{ print $1 }')" >> Packages
  # md5sum "$deb" | echo "MD5sum: $(awk '{ print $1 }')" >> Packages
  wc -c "$deb" | echo "Size: $(awk '{ print $1 }')" >> Packages
  echo "Filename: $deb" >> Packages
  dpkg-deb -f "$deb" Package
  #dpkg-deb -f "$deb" Package | echo "Depiction: http://$(head -n 1 CNAME)/depictions/?p=$(xargs -0)" >> Packages
  echo "" >> Packages
done

echo "" >> Packages; ## Add extra new line

bzip2 < Packages > Packages.bz2
gzip -9c < Packages > Packages.gz

./deploy.sh
# git add -A
# now=$(date +"%I:%M %m-%d-%Y")
# git commit -am "Packages Update - $now"
# git push

echo "Updated Github repository with latest packages";
cd "$cur"
