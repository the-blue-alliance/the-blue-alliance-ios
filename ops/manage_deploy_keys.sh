#! /bin/bash

# A file to build a tarball of key files that get encrypted for travis
# Any file in here should MOST DEFINITELY be in .gitignore
# Run this script from the root of the repo. Use -c to build the archive, -x to extract

while getopts "cx" o; do
    case "${o}" in
        c)
            echo "Creating key archive..."
            tar cvf ops/deploy_keys.tar ops/tbatv-prod-hrd-firebase-adminsdk.json
            ;;
        x)
            echo "Extracting key archive..."
            tar xvf ops/deploy_keys.tar
            ;;
        *)
            exit -1
            ;;
    esac
done

