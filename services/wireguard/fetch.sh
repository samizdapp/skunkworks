VERSION=$(curl https://api.balena-cloud.com/device-types/v1/$1/images |
	      # The latest development version, replacing + with %2B.
	      jq -r 'first(.versions[] | select(endswith("dev"))) | sub("\\+"; "%2B")')
curl -L https://files.balena-cloud.com/images/$1/$VERSION/kernel_modules_headers.tar.gz | tar xz

KERNEL_RELEASE=$(cat kernel_modules_headers/include/config/kernel.release)
dpkg --compare-versions $KERNEL_RELEASE ge 5.6 && exit 0

git clone https://git.zx2c4.com/wireguard-linux-compat
git clone https://git.zx2c4.com/wireguard-tools
