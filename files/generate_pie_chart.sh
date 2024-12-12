#!/bin/bash

RESULT_FILE="$1"
TEMP=$(mktemp)
XML_OUTPUT="$2"
XML_TEMP=$(mktemp)

generate_xml() {
  awk -v output="$TEMP" '
  {
    process = $1; core = $2; cpu = $3;
    gsub(/%/, "", cpu);  # Remove the percentage sign

    cpu_usage[core] += cpu;
    process_data[core, process] = cpu;
  }
  END {
    for (core in cpu_usage) {
      idle = 100 - cpu_usage[core];
      if (idle != 100){
        printf "<Result>\n" > output;
        printf "<Title>Core %s utilization</Title>\n", core > output;
        printf "<DisplayFormat>PIE_CHART</DisplayFormat>\n" > output;
        printf "<Data>\n" > output;

        for (key in process_data) {
            split(key, keys, SUBSEP);
            if (keys[1] == core) {
            printf "    <Entry>\n" > output;
            printf "      <Identifier>%s</Identifier>\n", keys[2] > output;
            printf "      <Value>%.2f</Value>\n", process_data[key] > output;
            printf "      <RawString></RawString>\n" > output;
            printf "    </Entry>\n" > output;
            }
        }
        printf "    <Entry>\n" > output;
        printf "      <Identifier>Idle</Identifier>\n" > output;
        printf "      <Value>%.2f</Value>\n", idle > output;
        printf "      <RawString></RawString>\n" > output;
        printf "    </Entry>\n" > output;
        printf "</Data>\n" > output;
        printf "</Result>\n" > output;
      }
    }
  }
  ' "$RESULT_FILE"
}

generate_xml
awk '
FNR==NR { b_data = b_data $0 "\n"; next } /<\/PhoronixTestSuite>/ { print b_data } 1
'  "$TEMP" "$XML_OUTPUT" > "$XML_TEMP"
mv "$XML_TEMP" "$XML_OUTPUT"
