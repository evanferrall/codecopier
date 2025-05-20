#!/bin/bash
set -euo pipefail

echo "Running Instruments capture"
# Placeholder command; adapt to project scheme once UI target exists
xcrun xctrace record --template "Time Profiler" --time-limit 60 \
  --output instrumentation_trace \
  --quit-after-instrumentation

