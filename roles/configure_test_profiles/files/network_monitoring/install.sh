# Copyright (C) 2024 Savoir-faire Linux, Inc.
# SPDX-License-Identifier: Apache-2.0

#!/bin/sh
# Auto-generated install.sh script for starting/helping the test profile creation process...

if which vnstat>/dev/null 2>&1 ;
then
	echo 0 > ~/install-exit-status
else
	echo "fatal: vnstat is not found on the system! This test profile needs a working vnstat installation in the PATH."
	echo 2 > ~/install-exit-status
fi

echo "#!/bin/bash
TRIGGER_FILE=/tmp/stop_waiting
LOG=/tmp/network_mon.log
touch \$LOG
while [ ! -f /tmp/start_monitoring ]; do
  sleep 1
done

vnstat -l -ru 0 --json \$@ > \$LOG&

while true; do
    if [[ -f "\$TRIGGER_FILE" ]]; then
        pkill vnstat -SIGINT
        while ! grep -q '"averageratestring"' \$LOG; do
            sleep 1
        done
        cat \$LOG |tail  --lines=1|jq '{rx_ratestrings: {max_rx: .rx.maxratestring, avg_rx: .rx.averageratestring, min_rx: .rx.minratestring}, tx_ratestrings: {max_tx: .tx.maxratestring, avg_tx: .tx.averageratestring, min_tx: .tx.minratestring}}'| tr -d '\"' > \$LOG_FILE
        exit 0
    fi
    sleep 1
done

" > ~/network_monitoring
chmod +x ~/network_monitoring

# Check out the `phoronix-test-suite debug-run` command when trying to
# debug your install/run behavior
