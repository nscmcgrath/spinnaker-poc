#!/bin/bash

set -x

/bin/cat <<EOM >manifest.yaml
simple: yaml
file: for
testing:
  deployment:
    output: results
EOM
