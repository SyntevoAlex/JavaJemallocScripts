#!/bin/bash

# Setting up your system:
# 1) Install jemalloc using your favourive packet manager of build from:
#    https://github.com/jemalloc/jemalloc
#    Note that if build yourself, you need to use '--enable-prof' option
# 2) Install debug infos for GTK, GLib
#    This is needed to properly ignore false positives.
#    Also, it will make it easier for you to understand the findings.
#    If your OS doesn't support debug infos, you might need to build from sources.

# How to use:
# 1) Prepend this script to your Java application commandline and run.
# 2) Find a new '*.heap' file in your current directory
#    Note that there will be one heap file per every child process your program runs.
#    Usually the biggest heap file is the one you want.
# 3) Use 'ParseHeapFile.sh' on this file to get human-readable output.

# --------------
# Configure GLib
# --------------

# Do not use GLib's internal allocators that will not be visible to leak detector
export G_SLICE=always-malloc

# --------------
# Configure jemalloc
# --------------

# prof_leak:true    - Enable leak reporting
# lg_prof_sample:0  - Disable sampling, we're only interested in leaks
# prof_final:true   - Capture the leaks in the final profile
export MALLOC_CONF=prof_leak:true,lg_prof_sample:0,prof_final:true
# Inject jemalloc into the target program
export LD_PRELOAD=libjemalloc.so.2

# --------------
# Run the application specified in commandline for this script.
# --------------

"$@"

