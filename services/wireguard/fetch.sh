KERNEL_RELEASE=$(cat kernel_modules_headers/include/config/kernel.release)
dpkg --compare-versions $KERNEL_RELEASE ge 5.6 && exit 0

git clone https://git.zx2c4.com/wireguard-linux-compat
git clone https://git.zx2c4.com/wireguard-tools
