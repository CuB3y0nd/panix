# panix

*A minimal Linux kernel development &amp; exploitation lab.*

Let's make the kernel panic *:evilface:*

## Prerequisite

All the dependencies for building the kernel.

## Build

Building the kernel, busybox, and demo modules:

```bash
./build
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

## FAQ

Q: pwndbg's `vmmap` is broken when debugging the kernel ?<br/>
A: You should turning `ptrace_scope` level to `0` in your host machine by `echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope`.
