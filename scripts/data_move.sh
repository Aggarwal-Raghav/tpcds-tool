#! /usr/bin/env bash

DIR_PATH=/tmp/data
DATA_PATH=/Users/raghav/Desktop/software/tpcds-generated-data

for i in $DIR_PATH/*
do

    dir_name=$(basename $i)
    data_dir=$(realpath $DATA_PATH/$dir_name*.dat | head -1)
    cp $data_dir $i
done
