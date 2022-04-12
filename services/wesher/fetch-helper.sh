BALENA_ARCH=$1
case $BALENA_ARCH in
    aarch64)
	WESHER_ARCH=arm64
	;;
    armv7hf)
	WESHER_ARCH=arm
	;;
    amd64)
	WESHER_ARCH=amd64
	;;
    *)
	echo "ERROR: Device not supported by either balena or wesher." >&2
	exit 1
	;;
esac

echo -n https://github.com/costela/wesher/releases/latest/download/wesher-$WESHER_ARCH
