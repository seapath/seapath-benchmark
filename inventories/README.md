<!-- Copyright (C) 2024 Savoir-faire Linux, Inc.
SPDX-License-Identifier: Apache-2.0 -->

# Inventories directory
This directory contains the inventory files used to configure the
benchmark used.

# Test profiles selection
Test profiles have to be defined for each host, in the inventory file.

For example, the following code run the test profile monitoring
`process_monitoring`, and the `disk`, `cpu` and `vm_migration` test-profiles
benchmark on `hypervisor1`.
