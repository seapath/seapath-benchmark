# Copyright (C) 2024 Savoir-faire Linux, Inc.
# SPDX-License-Identifier: Apache-2.0

#!/bin/sh
# Auto-generated install.sh script for starting/helping the test profile creation process...

if which cyclictest>/dev/null 2>&1 ;
then
	echo 0 > ~/install-exit-status
else
	echo "fatal: cyclictest is not found on the system! This test profile needs a working cyclictest installation in the PATH."
	echo 2 > ~/install-exit-status
fi

cat << 'EOF' > rt_tests
#!/bin/bash
cyclictest $@ > $LOG_FILE 2>&1
MAX_LATENCIES=$(grep "Max Latencies" "$LOG_FILE" | tr " " "\n" | sort -n | tail -1 | sed s/^0*//)
echo "Max Latency: $MAX_LATENCIES" >> $LOG_FILE
EOF

chmod +x rt_tests

# Check out the `phoronix-test-suite debug-run` command when trying to
# debug your install/run behavior
