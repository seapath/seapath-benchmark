# Copyright (C) 2024 Savoir-faire Linux, Inc.
# SPDX-License-Identifier: Apache-2.0

#!/bin/sh
# Auto-generated install.sh script for starting/helping the test profile creation process...

echo "#!/bin/bash

if [ -z \"\$1\" ] || [ -z \"\$2\" ]; then
    echo \"Usage: \$0 <resource> <iterations>\"
    exit 1
fi

RESOURCE=\$1
MIGRATION_ITERATIONS=\$2
RESULT=\$(mktemp)

generate_results() {
    awk -v iterations=\$MIGRATION_ITERATIONS '
    {
        sum += \$1;

        if (NR == 1 || \$1 < min) {
            min = \$1;
        }

        if (NR == 1 || \$1 > max) {
            max = \$1;
        }
    }
    END {
        avg = sum / iterations;
        printf \"Sum: %d\nAverage: %.2f\nMin: %d\nMax: %d\n\", sum, avg, min, max;
    }' "\$RESULT" > "\$LOG_FILE"
}


for ((i=0; i<MIGRATION_ITERATIONS; i++)); do
    start_migration=\$(date +%s)
    crm resource move \$RESOURCE force
    RESOURCE_STATUS=\$(crm resource status|grep \$RESOURCE|awk '{print \$4}')

    while [ "\$RESOURCE_STATUS" != "Started" ]
    do
        RESOURCE_STATUS=\$(crm resource status|grep \$RESOURCE|awk '{print \$4}')
        sleep 1
    done
    end_migration=\$(date +%s)
    echo "\$end_migration - \$start_migration"|bc -l >> \$RESULT
    crm resource clear \$RESOURCE
done

generate_results

" > ~/vm_migration
chmod +x ~/vm_migration
