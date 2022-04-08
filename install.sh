#!/bin/sh
if [ $# -ne 2 ]; then
    echo "No arguments, assuming amd64 build."
    set -- genericx86-64-ext amd64
fi

for TEMPLATE in services/*/Dockerfile.template; do
    DOCKERFILE=${TEMPLATE%.template}
    echo "Populating $DOCKERFILE"
    sed "$TEMPLATE" \
	-e "s/%%BALENA_MACHINE_NAME%%/$1/g" \
	-e "s/%%BALENA_ARCH%%/$2/g" \
	> "$DOCKERFILE"
done

docker-compose up --build
