#!/bin/sh

set -o pipefail

echo "::debug::Using input path: ${INPUT_INPUT_PATH}"
echo "::debug::Using output path: ${INPUT_OUTPUT_PATH}"

if [ -n "${INPUT_EXTRA_ARGS}" ]; then
  echo "::debug::Using specified extra args: ${INPUT_EXTRA_ARGS}"
  EXTRA_ARGS="${INPUT_EXTRA_ARGS}"
fi

cfn_nag_scan ${EXTRA_ARGS} --input-path "${INPUT_INPUT_PATH}" | tee "${INPUT_OUTPUT_PATH}"