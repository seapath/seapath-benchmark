#!/bin/bash
# Copyright (C) 2020, RTE (http://www.rte-france.com)
# Copyright (C) 2024 Savoir-faire Linux, Inc
# SPDX-License-Identifier: Apache-2.0

set -e

print_usage()
{
    echo "This script generates a latency graph based on cyclictest output
    For instance:
        $ cyclictest -l100000000 -m -Sp90 -i200 -h400 -q > output
        $ $0 -i output -o output.png

./$(basename "${0}") [OPTIONS]

Options:
        (-i|--input)            <path>            Input file to process
        (-o|--output)           <path>            Output file to process
        (-h|--help)                               Display this help message
        "
}

# Name:       parse_options
# Brief:      Parse options from command line
# Param[in]:  Command line parameters
parse_options()
{
    ARGS=$(getopt -o "hi:o:" -l "input:,output:" -n "$0" -- "$@")

    eval set -- "${ARGS}"

    while true; do
        case "$1" in
            -i|--input)
                export INPUT_FILE=$2
                shift 2
                ;;

            -o|--output)
                export OUTPUT_FILE=$2
                shift 2
                ;;

            -h|--help)
                print_usage
                exit 1
                shift
                break
                ;;

            -|--)
                shift
                break
                ;;

            *)
                print_usage
                exit 1
                shift
                break
                ;;
        esac
    done
    if  [ -z "$INPUT_FILE" ] ; then
        echo "Error: Missing input file"
        print_usage
        exit 1
    fi

    if  [ -z "$OUTPUT_FILE" ] ; then
        echo "Error: Missing output file"
        print_usage
        exit 1
    fi
}

# Name:       plot_graph
# Brief:      Plot a graph based on a plot file
# Param[in]:  Maximum latency to plot
# Param[in]:  Plot file to use
# Param[in]:  Output image file
# Param[in]:  Histogram file
# Param[in]:  X range
# Param[in]:  Number of cores
plot_graph()
{
    local max_latency=$1
    local plot_file=$2
    local output_file=$3
    local histogram_file=$4
    local xrange=$5
    local nb_cores=$6

    # Create plot command header
    echo -n -e "set title \"Latency plot\"\n\
    set terminal png\n\
    set xlabel \"Latency (us), max $max_latency us\"\n\
    set logscale y\n\
    set xrange [0:$xrange]\n\
    set yrange [0.8:*]\n\
    set ylabel \"Number of latency samples\"\n\
    set output \"$output_file\"\n\
    plot " >"$plot_file"

    # Append plot command data references
    for i in $(seq 1 $nb_cores); do
        if test $i != 1; then
            echo -n ", " >>"$plot_file"
        fi
        cpuno=$((i-1))
        if test $cpuno -lt 10; then
            title=" CPU$cpuno"
        else
            title="CPU$cpuno"
        fi
        echo -n "\"$histogram_file$i\" using 1:2 title \"$title\" with histeps" >>"$plot_file"
    done
    gnuplot -persist <"$plot_file"
}

# Name:       create_histogram
# Brief:      Create Histrogram file
# Param[in]:  Input file
create_histogram()
{
    local input_file=$1
    local histogram_file=$2
    # Grep data lines, remove empty lines and create a common field separator
    grep -v -e "^#" -e "^$" "$input_file" | tr " " "\t" >"$histogram_file"
}

# Name:       create_histogram_per_core
# Brief:      Create Histrogram file per core
# Param[in]:  Input file
create_histogram_per_core()
{
    local histogram_file=$1
    local nb_cores=$2
    # Create two-column data sets with latency classes and frequency values for each core, for example
    for i in `seq 1 $nb_cores`
    do
        column=$((i + 1))
        cut -f1,"$column" "$histogram_file" >"$histogram_file$i"
    done
}

# Name:       get_nb_cores
# Brief:      Get the number of cores
# Param[in]:  Input file
get_nb_cores()
{
    local input_file=$1
    echo $(($(head -n 7 "$input_file" | tail -n 1 | grep -oP '\t' | tr -d '\n' | wc -c) + 1))
}

# Name:       get_max_latency
# Brief:      Get the maximum latency
# Param[in]:  Input file
get_max_latency()
{
    local input_file=$1
    echo $(grep "Max Latencies" "$input_file" | tr " " "\n" | sort -n | tail -1 | sed s/^0*//)
}


# Name:    get_xrange
# Brief:   Get the maximum value of the x axis
# Param[in]:  Input file
get_xrange()
{
    local input_file=$1
    # We need to find the last histogram value and add 1 to it
    # The next line just after the histogram is the total
    local stop_line='# Total'
    local first_line='# Histogram'
    while read -r line; do
        if [ "$line" = "$first_line" ]; then
            continue
        elif echo "$line" | grep -q "$stop_line"; then
            break
        else
            i=$(echo "$line" | cut -d ' ' -f1)
        fi
    done < "$input_file"
    if [ -z "$i" ]; then
        echo "Error: Cannot find the last histogram value" 2>&1
        exit 1
    fi
    # Strip leading zeros
    echo $((10#$i + 1))
}

##########################
########## MAIN ##########
##########################

#### Local vars ####

# Keep directory to retrieve tools
TEMP_DIR=$(mktemp -d)
HISTOGRAM_FILE="$TEMP_DIR/histogram"
PLOT_FILE="$TEMP_DIR/plotcmd"

# Not verbose by default
if [ -z "$VERBOSE" ]; then
    export VERBOSE=0
fi

# Parse options
parse_options "${@}"

max_latency=$(get_max_latency "$INPUT_FILE")
xrange=$(get_xrange "$INPUT_FILE")
if [ $max_latency -lt $xrange ]; then
    # Rounding up to the nearest power of 10 (e.g. 1234 -> 2000)
    number_of_digits=$(echo -n $max_latency | wc -c)
    msd=$(echo -n $max_latency | head -c 1)
    if [ $(( max_latency - (10 ** (number_of_digits - 1) * msd) )) -eq 0 ]; then
        # No need to round up
        xrange=$max_latency
    else
        xrange=$(( 10  ** (number_of_digits - 1) * (msd + 1) ))
    fi
fi
nb_cores=$(get_nb_cores "$INPUT_FILE")
create_histogram "$INPUT_FILE" "$HISTOGRAM_FILE"
create_histogram_per_core "$HISTOGRAM_FILE" "$nb_cores"
plot_graph "$max_latency" "$PLOT_FILE" "$OUTPUT_FILE" "$HISTOGRAM_FILE" "$xrange" "$nb_cores"
echo "Max Latency found=$max_latency us"
