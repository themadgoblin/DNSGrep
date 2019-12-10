# fetch the rdns file
wget -O cname.gz https://opendata.rapid7.com/sonar.fdns_v2/2019-11-25-1574640596-fdns_cname.json.gz

# extract and format our data
gunzip -c cname.gz | jq -r '.name + ","+ .value' | tr '[:upper:]' '[:lower:]' | rev > cname.rev.lowercase.txt

# split the data into chunks ot sort
split -b100M cname.rev.lowercase.txt fileChunk

# remove the old files
rm cname.gz
rm cname.rev.lowercase.txt

## Sort each of the pieces and delete the unsorted one
for f in fileChunk*; do LC_COLLATE=C sort "$f" > "$f".sorted && rm "$f"; done

## merge the sorted files with local tmp directory
mkdir -p sorttmp
LC_COLLATE=C sort -T sorttmp/ -muo cname.sort.txt fileChunk*.sorted

# clean up
rm fileChunk*
