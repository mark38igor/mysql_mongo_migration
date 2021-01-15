#!/bin/bash
# path where json files are stored
target="/home/sbabukuttan/Documents/mysql to mongo migration/json/$1"
let count=0
# iterate over the directory mentioned above
for f in "$target"/*
do
    # get filename with extension
    echo $(basename "$f")
    let count=count+1
    # split the filename using the delimiter character _ and use first set of characters for the collection name in mongo
    collection_name=$(echo $(basename "$f")| cut -d'_' -f 1)
    echo $collection_name
    # execute mongo import command
    mongoimport /home/sbabukuttan/Documents/mysql\ to\ mongo\ migration/json/$(basename "$f") -d classicModels -c $collection_name --jsonArray --drop 
done
echo ""
echo "Count: $count"
