#!/bin/bash -e

RESULT_FILE="$1"
TEMP=$(mktemp)
XML_OUTPUT="$2"
XML_TEMP=$(mktemp)
MONITOR_PROCESSES="${3:-}" # Comma-separated list of processes to monitor

generate_xml() {
  awk -F ';' -v output="$TEMP" -v monitor="$MONITOR_PROCESSES" -f /usr/bin/generate_pie_chart_xml.awk "$RESULT_FILE"
}

generate_xml
awk '
FNR==NR { b_data = b_data $0 "\n"; next } /<\/PhoronixTestSuite>/ { print b_data } 1
' "$TEMP" "$XML_OUTPUT" > "$XML_TEMP"
mv "$XML_TEMP" "$XML_OUTPUT"

# Clean up temporary files
rm -f "$TEMP"
