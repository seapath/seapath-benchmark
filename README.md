<!-- Copyright (C) 2024 Savoir-faire Linux, Inc.
SPDX-License-Identifier: Apache-2.0 -->

# seapath-benchmark

seapath-benchmark is a tool used to evaluate the performance of a SEAPATH
cluster infrastructure and its components.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Available tests](#available-tests)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Release notes](#release-notes)

## Introduction

seapath-benchmark is designed to provide a test architecture to measure
and monitor the performance of a SEAPATH infrastructure.
seapath-benchmark is build upon two core elements:
- The phoronix-test-suite to provide a test backend: test skeleton,
  test management, results handling, report generation
- Ansible as an orchestrator, used to the run the configuration and
  execution of tests across various physical and virtual machines.

seapath-benchmark can benchmark various system components (CPU, disk),
SEAPATH features (VM migration), and can monitor the resource usage on
each machine.

seapath-benchmark can be used (with the exception for cluster specific
tests) on standalone and cluster SEAPATH configuration.

Results are available in the directory `test-results`, at the end of
each test.


## Features
- Tests benchmark for testing the performance of various system and
  SEAPATH components
- Monitoring of various system sensors and resource usage
- Tests results generation in various format with pretty graphs

## Available tests

Following phoronix-test-suite typology, seapath-benchmark tests are
called `test profiles`. Test profiles can be one of two types:
- Monitoring test profiles: these tests are used to only monitor various
  system and SEAPATH sensors (ex: CPU/memory/disk usage, bandwith
  consumption, etc.)
- Benchmark test profiles: these tests are used to measure the
  performance of a particular system or SEAPATH components (ex: CPU,
  memory, disk, VM migration...)

| Name | Test profiles type | Tested components | Compatible machines and infrastructure | Test arguments | Generated results | Needed dependencies |
| -------- | ------- | ------- | ------- | ------- | ------- | ------- |
| cpu | Benchmark | CPU | Hypervisor and VMs, all SEAPATH configuration | / | PDF report with sysbench score | sysbench |
| disk | Benchmark | Disk | Hypervisor and VMs, all SEAPATH configuration | / | PDF report with fio score | fio |
| vm_migration | Benchmark | CPU, disk | Hypervisor and VMs, only SEAPATH cluster configuration |- `resource`: name of the VM to migrate (default `guest0`) <br> - `iterations`: number of VM migration (default 5) | PDF report with average VM migration time | A working SEAPATH cluster using crm as resource manager |
| process_monitoring | Monitoring | / | Hypervisor and VMs, all SEAPATH configuration | `processes_to_monitor`: list of processes to monitor separated by a coma `,`. If not provided, only shows the three most CPU consumer processes | HTML report with process CPU consumption per CPU core | / |


## Installation
### Requirements
#### System packages

Make sure your localhost system complies with the following dependencies:
```bash
sudo apt install \
docker
```

Install `cqfd`:
```bash
git clone https://github.com/savoirfairelinux/cqfd.git
cd cqfd
sudo make install
```

Normally, seapath-benchmark is designed to be run on localhost inside a
Docker container. If you wish to run seapath-benchmark directly on the
localhost machine, make sure it complies with the following
dependencies:

```bash
sudo apt install \
ansible \
bash
```

## Requirements
Make sure the phoronix-test-suite package is installed on each tested machines:
1. Get the phoronix-test-suite at [phoronix-test-suite](https://github.com/phoronix-test-suite/phoronix-test-suite/archive/refs/heads/master.zip)
2. Unzip the archive
3. Run the file `install.sh`

For Debian based distribution:
``` wget https://github.com/phoronix-test-suite/phoronix-test-suite/releases/download/v10.8.4/phoronix-test-suite_10.8.4_all.deb
apt install phoronix-test-suite_10.8.4_all.deb
```

Then make sure following dependencies are satisfied on each tested machine:
```
apt-get install \
librsvg2-bin \
patch \
php-xml
```





The user used by Ansible, targeted by inventory variable `ansible_user`
variable must be configured on each machine to have sudo access.

## Usage
### Configuration

Machines and tests configuration have to be set in a dedicated Ansible
inventory. See `inventories/README` for more information.
Configuration can then be started using:

```
cqfd -b configure_test_profiles
```
or
```
cqfd run ansible-playbook -i inventories/<YOUR INVENTORY> playbooks/configure_test_profiles.yaml
```

### Run tests

Selected tests profiles in inventory file can be started using:

```
cqfd -b run_test_profiles
```

or

```
cqfd run ansible-playbook -i inventories/<YOUR INVENTORY> playbooks/run_test_profiles.yaml
```

## Release notes

### Version v0.1

* Configuration of the machines and the test profiles
* Add CPU, disk, vm_migration benchmark test profiles
* Add process_monitoring monitoring test profile
* Generation of results per test-profiles

### Version v0.2

General:
* Rename test profiles without '-' character
* Add support for patching target files
* Add packages dependency check
* Various bug fixes and improvements

Process_monitoring:
* Generate report in PDF format, with the support of pie charts
* Show only in the generated diagrams the 3 most CPU consuming
  processes, other processes are in a category "Others"
* Add a possibility to monitor only desired processes with
  `processes_to_monitor` argument

Vm_migration:
* Add optional test-profiles arguments `resource` and `iterations`
