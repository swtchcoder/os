KERNEL_VERSION=6.18.8
KERNEL_MAJOR=6
BUSYBOX_VERSION=1.37.0
THREADS=4

build: bzImage initramfs

bzImage: linux-$(KERNEL_VERSION)
	$(MAKE) -C linux-$(KERNEL_VERSION) defconfig
	$(MAKE) -C linux-$(KERNEL_VERSION) -j $(THREADS)
	cp linux-$(KERNEL_VERSION)/arch/x86/boot/bzImage .

linux-$(KERNEL_VERSION): linux-$(KERNEL_VERSION).tar.xz
	tar -xf linux-$(KERNEL_VERSION).tar.xz

linux-$(KERNEL_VERSION).tar.xz:
	wget https://cdn.kernel.org/pub/linux/kernel/v$(KERNEL_MAJOR).x/linux-$(KERNEL_VERSION).tar.xz

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
	rm -rf bzImage
	rm -rf busybox-$(BUSYBOX_VERSION).tar.bz2 busybox-$(BUSYBOX_VERSION)
	rm -rf initramfs
