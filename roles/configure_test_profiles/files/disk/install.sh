# Copyright (C) 2024 Savoir-faire Linux, Inc.
# SPDX-License-Identifier: Apache-2.0

#!/bin/sh
# Auto-generated install.sh script for starting/helping the test profile creation process...

if which fio>/dev/null 2>&1 ;
then
	echo 0 > ~/install-exit-status
else
	echo "fatal: fio is not found on the system! This test profile needs a working fio installation in the PATH"
	echo 2 > ~/install-exit-status
fi

echo "#!/bin/bash
    fio --name=random-writers --ioengine=libaio --iodepth=4 --rw=randwrite --bs=32k --direct=0 --numjobs=1 \$@ > \$LOG_FILE 2>&1
    echo \$? > ~/test-exit-status" > ~/disk
chmod +x ~/disk

# Check out the `phoronix-test-suite debug-run` command when trying to
# debug your install/run behavior
