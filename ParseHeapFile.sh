#!/bin/bash

SCRIPT_DIR=`dirname "$0"`
JAVA_PATH=`which java`

# ----------------
# Import ignore patterns
# ----------------
source "$SCRIPT_DIR/Internal/ignorePatterns.sh"

# ----------------
# Set up jeprof options
# ----------------
JEPROF_ARGS=()
# Use number of bytes leaked as the number reported per stack
JEPROF_ARGS+=("--show_bytes")
# Output format: stacks sorted by number of bytes leaked
JEPROF_ARGS+=("--stacks")
# Report even the smallest leaks
JEPROF_ARGS+=(--edgefraction=0 --nodefraction=0)
# Ignore various false positives
JEPROF_ARGS+=(--ignore="$JEPROF_IGNORE_REGEX")
# Give path to java executable, probably used when matching debug infos
JEPROF_ARGS+=("$JAVA_PATH")

# ----------------
# Run jeprof
# ----------------
"$SCRIPT_DIR/Internal/jeprof" "${JEPROF_ARGS[@]}" "$1"

