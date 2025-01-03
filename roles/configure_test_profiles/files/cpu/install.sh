# Copyright (C) 2024 Savoir-faire Linux, Inc.
# SPDX-License-Identifier: Apache-2.0

#!/bin/sh
# Auto-generated install.sh script for starting/helping the test profile creation process...

if which sysbench>/dev/null 2>&1 ;
then
	echo 0 > ~/install-exit-status
else
	echo "fatal: sysbench is not found on the system! This test profile needs a working sysbench installation in the PATH."
	echo 2 > ~/install-exit-status
fi

echo "#!/bin/bash
    sysbench cpu run --threads=500 \$@ > \$LOG_FILE 2>&1
    echo \$? > ~/test-exit-status" > ~/cpu
chmod +x ~/cpu

# Check out the `phoronix-test-suite debug-run` command when trying to
# debug your install/run behavior
