BEGIN {
  # If monitor is provided, split it into an array
  if (monitor != "") {
    split(monitor, monitored_processes, ",");
    for (i in monitored_processes) {
      monitored[monitored_processes[i]] = 1;
    }
  }
}

{
  process = $1; core = $2; cpu = $3;
  gsub(/%/, "", cpu);  # Remove the percentage sign
  gsub(/[ \t]/, "", core);

  # Collect CPU usage by core and process
  cpu_usage[core] += cpu;
  process_data[core, process] = cpu;
}

END {
  for (core in cpu_usage) {
    idle = 100 - cpu_usage[core];
    if (idle != 100) {
      printf "<Result>\n" > output;
      printf "<Title>Core %s utilization</Title>\n", core > output;
      printf "<DisplayFormat>PIE_CHART</DisplayFormat>\n" > output;
      printf "<Data>\n" > output;

      # Collect processes and their CPU usage for sorting
      n = 0;
      for (key in process_data) {
        split(key, keys, SUBSEP);
        if (keys[1] == core) {
          n++;
          processes[n] = keys[2];
          cpu_values[n] = process_data[key];
        }
      }

      # Sort processes by CPU usage in descending order
      for (i = 1; i <= n; i++) {
        for (j = i + 1; j <= n; j++) {
          if (cpu_values[i] < cpu_values[j]) {
            tmp_val = cpu_values[i]; cpu_values[i] = cpu_values[j]; cpu_values[j] = tmp_val;
            tmp_proc = processes[i]; processes[i] = processes[j]; processes[j] = tmp_proc;
          }
        }
      }

      # Output selected processes or top 3 processes
      others = 0;
      count = 0;
      for (i = 1; i <= n; i++) {
        if (monitor != "") {
          # If specific processes are monitored
          if (processes[i] in monitored) {
            printf "    <Entry>\n" > output;
            printf "      <Identifier>%s</Identifier>\n", processes[i] > output;
            printf "      <Value>%.2f</Value>\n", cpu_values[i] > output;
            printf "      <RawString></RawString>\n" > output;
            printf "    </Entry>\n" > output;
          } else {
            others += cpu_values[i];
          }
        } else {
          # Default behavior: show top 3 processes
          if (count < 3) {
            printf "    <Entry>\n" > output;
            printf "      <Identifier>%s</Identifier>\n", processes[i] > output;
            printf "      <Value>%.2f</Value>\n", cpu_values[i] > output;
            printf "      <RawString></RawString>\n" > output;
            printf "    </Entry>\n" > output;
            count++;
          } else {
            others += cpu_values[i];
          }
        }
      }

      # Add "Others" if applicable
      if (others > 0) {
        printf "    <Entry>\n" > output;
        printf "      <Identifier>Others</Identifier>\n" > output;
        printf "      <Value>%.2f</Value>\n", others > output;
        printf "      <RawString></RawString>\n" > output;
        printf "    </Entry>\n" > output;
      }

      # Add "Idle"
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
