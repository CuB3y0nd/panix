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
