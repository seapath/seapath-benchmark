# Copyright (C) 2024 Savoir-faire Linux, Inc.
# SPDX-License-Identifier: Apache-2.0

#!/bin/sh
# Auto-generated install.sh script for starting/helping the test profile creation process...


echo "#!/bin/bash
TRIGGER_FILE=/tmp/stop_waiting
LOG=/tmp/log
RESULT=\$(mktemp)

generate_results() {
    awk -v iteration=\$ITERATION '
    {
        cpu = \$1;
        mem = \$2;
        iow = \$3;
        process = \$4;
        core = \$5;

        cpu_data[process, core] += cpu;
        mem_data[process, core] += mem;
        iow_data[process, core] = iow;
        iterations[process, core]++;
    }
    END {
        printf \"%-43s %-8s %8s %8s %20s\n\", \"Process\", \"Core\", \"CPU%\", \"MEM%\", \"IOW\";
        for (key in cpu_data) {
            split(key, keys, SUBSEP);
            proc = keys[1];
            core = keys[2];

            avg_cpu = cpu_data[key] / iteration;
            avg_mem = mem_data[key] / iteration;
            raw_iow = iow_data[key]
            printf \"%-43s %-8s %8.2f%% %8.2f%% %20s\n\", proc, core, avg_cpu, avg_mem, raw_iow;
        }
    }
    ' "\$LOG" > "\$RESULT"

    {
        head -n1 "\$RESULT";
        tail -n +2 "\$RESULT" | sort -k3 -r;
    } > "\${RESULT}.sorted"

    mv "\${RESULT}.sorted" "\$RESULT"

}

clean() {
    rm -f "\$TRIGGER_FILE"
    rm -rf "\$LOG"
    rm -rf "\$RESULT"
}

clean
touch /tmp/results
ITERATION=0

while true; do
    if [[ -f "\$TRIGGER_FILE" ]]; then
        generate_results
        mv "\$RESULT" /tmp/results
        echo "Result: PASS" > "\$LOG_FILE"
        clean
        exit 0
    fi

    top -b -n1 | sed -n '/CPU/,\$p' | sed '/CPU/d' | head -n5 >> "\$LOG"
    ITERATION=\$((ITERATION + 1))
    sleep 1
done

" > ~/process_monitoring
chmod +x ~/process_monitoring

# Check out the `phoronix-test-suite debug-run` command when trying to
# debug your install/run behavior
