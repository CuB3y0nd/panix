KERNEL_VERSION=5.4

# add your own modules here!
obj-m = example.o

all:
	echo $(OBJECTS)
	make -C ../linux-$(KERNEL_VERSION) M=$(PWD) modules

clean:
	make -C ../linux-$(KERNEL_VERSION) M=$(PWD) clean
