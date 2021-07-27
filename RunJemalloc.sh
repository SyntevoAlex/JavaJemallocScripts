#!/bin/bash

# Setting up your system:
# 1) Install jemalloc using your favourive packet manager of build from:
#    https://github.com/jemalloc/jemalloc
#    Note that if build yourself, you need to use '--enable-prof' option
# 2) Install debug infos for GTK, GLib
#    This is needed to properly ignore false positives.
#    Also, it will make it easier for you to understand the findings.
#    If your OS doesn't support debug infos, build GTK/GLib from sources.

# How to use:
# 1) Prepend this script to your Java application commandline and run.
# 2) Find a new '*.heap' file in your current directory
#    Note that there will be one heap file per every child process your program runs.
#    Check console output at the very end to figure which file is related to your main program.
# 3) Use 'ParseHeapFile.sh' on this file to get human-readable output.

# --------------
# Configure GLib
# --------------

# Do not use GLib's internal allocators that will not be visible to leak detector
export G_SLICE=always-malloc

# --------------
# Configure jemalloc
# --------------

# prof:true           - Enable memory profiling
# prof_leak:true      - Print a summary of leaks to console when program exits
#                       Helpful, but not really needed.
#                       Can be disabled if it stands in the way.
# prof_final:true     - Save a '*.heap' dump with all detected leaks
# lg_prof_sample:0    - Record heap allocation backtrace on every allocation
#                       Measured as the desired power of 2 of bytes of allocation activity.
#                       The value can be increased for speed/quality tradeoff.
# lg_prof_interval:-1 - Don't create regular '*.heap' dumps.
#                       This is the default, the option is listed only to mention it.
#                       Can be edited to the desired power of 2 of bytes of allocation activity.
#                       For example, 'lg_prof_interval:30' will make a dump per every 1gb.
export MALLOC_CONF=prof:true,prof_leak:true,prof_final:true,lg_prof_sample:0,lg_prof_interval:-1
# Inject jemalloc into the target program
export LD_PRELOAD=libjemalloc.so.2

# --------------
# Run the application specified in commandline for this script.
# --------------

"$@"

