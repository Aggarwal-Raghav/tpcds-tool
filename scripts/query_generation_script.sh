#! /bin/bash

function usage
{
    echo "$0 <scale>"
    echo "    scale in GB is one of 100, 300, 1000, 3000, 10000, 30000, 100000"
    echo ""
    exit
} # end function usage

function fix_query_template
{
    # add following line to beginning of each query template file
    #define _END = "";
    for file in $(find $TEMPLATEDIR -name "query*.tpl")
    do
        echo Processing $file
        # Remove line if exists
        sed -i '/^define _END = "";/d' $file
        # Add line to beginning
        sed -i '1s/^/define _END = "";\n/' $file
    done
} # end function fix_query_template

function fix_netezza_template
{
    # append 'define _END = "";' to netezza.tpl
    file="$TEMPLATEDIR/netezza.tpl"
    echo Processing $file
    # Remove line if exists
    sed -i '/^define _END = "";/d' $file
    # Append line to file
    echo 'define _END = "";' >> $file
} # end function fix_netezza_template

function gen_query_alt
{
    # Generate queries from template for given scale
    for i in `seq 1 99`
    do
        j=$(printf "%03d" $i) #i=1 j=001

        cmd="echo query${i}.tpl > $TEMPLATEDIR/templates_${i}.lst"
        echo "$cmd"; eval "$cmd"

        cmd="$TOOLSDIR/dsqgen -directory $TEMPLATEDIR -input $TEMPLATEDIR/templates_${i}.lst -distributions $TOOLSDIR/tpcds.idx -verbose y -qualify y -scale $SCALE -dialect netezza -output_dir $OUTDIR -rngseed $SEED"
        echo "$cmd"; eval "$cmd"

        cmd="mv $MV_OPTION $OUTDIR/query_0.sql $OUTDIR/query${j}.sql"
        echo "$cmd"; eval "$cmd"
        echo ""
    done
} # end function gen_query_alt

function gen_query
{
    # Generate queries from template for given scale
    pushd $TOOLSDIR
    for fullfile in `ls $TEMPLATEDIR/query*.tpl`
    do
        echo $fullfile
        filename=$(basename -- "$fullfile")
        filename="${filename%.*}"
        i=`echo "$filename"|cut -c 6-`

        j=$(printf "%03d" $i)
        # filename=query9 i=9 j=009
        #echo $filename $i $j

        \rm -f $OUTDIR/query_0.sql
        #cmd="./dsqgen -directory ../query_templates -template query${i}.tpl -distributions $TOOLSDIR/tpcds.idx -verbose y -qualify y -scale $SCALE -dialect netezza -output_dir $OUTDIR -rngseed $SEED"
        cmd="./dsqgen -directory ../query_templates -template query${i}.tpl -verbose y -scale $SCALE -dialect netezza -output_dir $OUTDIR -rngseed $SEED"
        echo "$cmd"; eval "$cmd"

        cmd="mv $MV_OPTION $OUTDIR/query_0.sql $OUTDIR/query${j}.sql"
        echo "$cmd"; eval "$cmd"
        echo ""
    done
    popd
} # end function gen_query

function gen_query_variant
{
    # Generate query variants from template for given scale
    pushd $TOOLSDIR
    \cp $TEMPLATEDIR/netezza.tpl $TEMPLATEVARIANTDIR/netezza.tpl
    for fullfile in `ls $TEMPLATEVARIANTDIR/query*.tpl`
    do
        echo $fullfile
        filename=$(basename -- "$fullfile")
        filename="${filename%.*}"
        lastchar=`echo "${filename: -1}"`
        i=`echo "$filename"|rev|cut -c 2-|rev|cut -c 6-`
        j=$(printf "%03d" $i)
        # filename=query10a i=10 j=010 lastchar=a
        #echo $filename $i $j $lastchar

        cmd="./dsqgen -directory ../query_variants -template query${i}${lastchar}.tpl -verbose y -scale $SCALE -dialect netezza -output_dir $OUTDIR -rngseed $SEED"
        echo "$cmd"; eval "$cmd"

        cmd="mv $MV_OPTION $OUTDIR/query_0.sql $OUTDIR/query${j}${lastchar}.sql"
        echo "$cmd"; eval "$cmd"
        echo ""
    done
    popd
} # end function gen_query_variant

function fix_query
{
    # Generate queries from template for given scale
    for f in `ls $OUTDIR/*.sql`
    do
        # Change file in-place
        # Match lines that don't have 'interval'
        # Search for pattern '(one or more space)(one or more digits)(one or more space)days'
        # Replace with " interval '(digits matched) days'"
        # e.g. change "  14 days" to  "interval '14 days'"
        # query030.sql has an error, c_last_review_date_sk should be c_last_review_date
        cmd="sed -i -E -e \"/interval/!s/([ ]+)([0-9]+)([ ]+)days/ interval '\2 days'/gi\" -e \"s/c_last_review_date_sk/c_last_review_date/gi\" $f"
        echo "$cmd"
        eval "$cmd"

        cmd="chmod 444 $f"
        echo "$cmd"
        eval "$cmd"
    done
} # end function fix_query

#-----------------------------------------------
# Main
#-----------------------------------------------

if [ "$#" != 1 ] || [ "$1" == "-h" ]
then
    usage
fi

SCALE="$1" # in GB
case $SCALE in
    100 | 300 | 1000 | 3000 | 10000 | 30000 | 100000) ;;
    *) usage ;;
esac

SCRIPTDIR=$PWD
BASEDIR="$SCRIPTDIR/.."
TOOLSDIR="$BASEDIR/DSGen-software-code-3.2.0rc1/tools"
TEMPLATEDIR="$BASEDIR/DSGen-software-code-3.2.0rc1/query_templates"
TEMPLATEVARIANTDIR="$BASEDIR/DSGen-software-code-3.2.0rc1/query_variants"
OUTDIR="$BASEDIR/sql/$SCALE"
OVERWRITE=yes
MV_OPTION=" -n " # no clobber

if [ ! -d "$TOOLSDIR" ]
then
    echo "Error: $TOOLSDIR is missing"
    exit
fi

if [ ! -d "$TEMPLATEDIR" ]
then
    echo "Error: $TEMPLATEDIR is missing"
    exit
fi

if [ "$OVERWRITE" = "yes" ]
then
    MV_OPTION=" -f "
else
    MV_OPTION=" -n " # no clobber
    if [ -d "$OUTDIR" ]
    then
        echo "Error: $OUTDIR already exists, I won't overwrite"
        exit
    fi
fi

mkdir -p $OUTDIR

# Default value for rngseed in qgen_params.h and params.h in
# tpc-ds_v3.2.0_compiled/DSGen-software-code-3.2.0rc1/tools
SEED="19620718"

# -----------------------------
# Don't run these
# -----------------------------
# No need to fix each query template, instead just fix netezza template
#fix_query_template
#gen_query_alt # Alternative to gen_query

# -----------------------------
# Run these
# -----------------------------
# echo "We should not be running these because we have already generated the queries! Hence exiting." && exit
fix_netezza_template
gen_query
gen_query_variant
fix_query
