KERNEL_VERSION=6.18.8
KERNEL_MAJOR=6
BUSYBOX_VERSION=1.37.0
THREADS=6

build: boot.img

boot.img: bzImage init.cpio
	dd if=/dev/zero of=boot.img bs=1M count=50
	mkfs -t fat boot.img
	syslinux boot.img
	mkdir -p m
	mount boot.img m
	cp syslinux.cfg m
	cp bzImage init.cpio m
	umount m

bzImage: linux-$(KERNEL_VERSION)
	$(MAKE) -C linux-$(KERNEL_VERSION) defconfig
	$(MAKE) -C linux-$(KERNEL_VERSION) -j $(THREADS) bzImage
	cp linux-$(KERNEL_VERSION)/arch/x86/boot/bzImage .

linux-$(KERNEL_VERSION): linux-$(KERNEL_VERSION).tar.xz
	tar -xf linux-$(KERNEL_VERSION).tar.xz

linux-$(KERNEL_VERSION).tar.xz:
	wget https://cdn.kernel.org/pub/linux/kernel/v$(KERNEL_MAJOR).x/linux-$(KERNEL_VERSION).tar.xz

init.cpio: initramfs
	cp init initramfs
	rm -f initramfs/linuxrc
	cd initramfs && find .| cpio -o -H newc > ../init.cpio

initramfs: busybox-$(BUSYBOX_VERSION)
	$(MAKE) -C busybox-$(BUSYBOX_VERSION) defconfig
	sed -i "s/CONFIG_STATIC=n/CONFIG_STATIC=y/" busybox-$(BUSYBOX_VERSION)/.config
	sed -i "s/CONFIG_TC=y/CONFIG_STATIC=n/" busybox-$(BUSYBOX_VERSION)/.config
	sed -i "s/CONFIG_WERROR=y/CONFIG_WERROR=n/" busybox-$(BUSYBOX_VERSION)/.config
	$(MAKE) -C busybox-$(BUSYBOX_VERSION) -j $(THREADS)
	mkdir initramfs
	$(MAKE) CONFIG_PREFIX=../initramfs -C busybox-$(BUSYBOX_VERSION) install

busybox-$(BUSYBOX_VERSION): busybox-$(BUSYBOX_VERSION).tar.bz2
	tar -xf busybox-$(BUSYBOX_VERSION).tar.bz2

busybox-$(BUSYBOX_VERSION).tar.bz2:
	wget https://busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2

clean:
	rm -rf linux-$(KERNEL_VERSION).tar.xz linux-$(KERNEL_VERSION)
	rm -f bzImage
	rm -rf busybox-$(BUSYBOX_VERSION).tar.bz2 busybox-$(BUSYBOX_VERSION)
	rm -rf initramfs
	rm -f init.cpio
	rm -f boot.img m
