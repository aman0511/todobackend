#!/bin/bash

# Activate virtual environment

. /appenv/bin/activate

# download requirements to build cache

cat requirements_test.txt

pip download -d /build -r requirements_test.txt --exists-action=i

pip install --no-index -f /build -r requirements_test.txt

echo $"install done"

ls

exec $@