#!/bin/bash

# How to use:
# 0) Install jemalloc using your favourive packet manager of build from:
#    https://github.com/jemalloc/jemalloc
# 1) Prepend this script to your Java application commandline and run.
# 2) Find a new '*.heap' file in your current directory
#    Note that there will be one file per every child process your program runs.
#    One way of picking the right file is choosing the biggest one.
# 3) Use 'ParseHeapFile.sh' on this file to get human-readable output.

# ----------------

# Configure jemalloc
# prof_leak:true    - Enable leak reporting
# lg_prof_sample:0  - Disable sampling, we're only interested in leaks
# prof_final:true   - Capture the leaks in the final profile
export MALLOC_CONF=prof_leak:true,lg_prof_sample:0,prof_final:true
# Inject jemalloc into the target program
export LD_PRELOAD=libjemalloc.so.2

# Run the application specified in commandline for this script.
"$@"
