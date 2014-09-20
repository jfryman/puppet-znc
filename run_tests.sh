#!/bin/sh -ex

echo "puppet=`puppet --version`"
echo "puppet-lint=`puppet-lint --version | awk '{print $NF}'`"

find . -name '*.pp' | xargs -P1 -L1 puppet parser validate \
          --parser future \
          --verbose

find . -name '*.pp' | xargs -P1 -L1 puppet-lint \
          --fail-on-warnings \
          --with-context \
          --with-filename \
          --no-80chars-check \
          --no-variable_scope-check \
          --no-nested_classes_or_defines-check \
          --no-autoloader_layout-check \
          --no-class_inherits_from_params_class-check
