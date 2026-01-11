# panix

*A minimal Linux kernel development &amp; exploitation lab.*

Let's make the kernel panic *:evilface:*

## Prerequisite

Docker + Docker BuildKit

## Build

Building the kernel, busybox inside the docker environment:

```bash
./install
```

By default, it will build `kernel-5.4` and `busybox-1.36.1`, you can change it in Dockerfile or pass as argument like `--build-arg KERNEL_VERSION_ARG=`, and newer kernel version might need newer glibc version, so you should change the ubuntu version which used in `builder` stage.

After build, it'll result 2 release files in this directory, you should extract kernel by:

```bash
tar -zxvf linux-5.4.tar.gz
```

## Launch

Running the kernel:

```bash
./launch
```

All modules will be in `/`, ready to be insmoded, and the host's home directory will be mounted as `/home/panix` in the guest.

## Debug

Running your favourite debugger in another terminal and use the following commands to attach to the kernel:

```bash
gdb ./linux-6.12.61/vmlinux
pwndbg> target remote :1234
```

## LKM modules

You can putting your own LKM module source files in `src` directory and build them by running `./build_lkm`. After build, re-run the emulate script to apply, it will be lye on root directory.

## FAQ

Q: pwndbg's `vmmap` is broken when debugging the kernel ?<br/>
A: You should turning `ptrace_scope` level to `0` in your host machine by `echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope`.
