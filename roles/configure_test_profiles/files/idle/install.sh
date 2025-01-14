#!/bin/sh

echo "#!/bin/sh
SLEEPTIME=\$((\$time_to_run ))
echo \"Sleeping for \$time_to_run secondes.\"
sleep \$SLEEPTIME
echo \"Result: PASS\" > \$LOG_FILE" > idle
chmod +x idle
