KERNEL_VERSION=6.18.8
KERNEL_MAJOR=6

build: linux-$(KERNEL_VERSION)
	$(MAKE) -C linux-$(KERNEL_VERSION) defconfig
	$(MAKE) -C linux-$(KERNEL_VERSION) -j $(nproc)

linux-$(KERNEL_VERSION): linux-$(KERNEL_VERSION).tar.xz
	tar -xf linux-$(KERNEL_VERSION).tar.xz

linux-$(KERNEL_VERSION).tar.xz:
	wget https://cdn.kernel.org/pub/linux/kernel/v$(KERNEL_MAJOR).x/linux-$(KERNEL_VERSION).tar.xz

clean:
	rm -rf linux-$(KERNEL_VERSION).tar.xz linux-$(KERNEL_VERSION)
