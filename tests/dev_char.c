#include <linux/fs.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/uaccess.h>

MODULE_LICENSE("GPL");

static int major_number;

static int device_open(struct inode *inode, struct file *filp) {
  printk(KERN_ALERT "Device opened.");
  return 0;
}

static int device_release(struct inode *inode, struct file *filp) {
  printk(KERN_ALERT "Device closed.");
  return 0;
}

static ssize_t device_read(struct file *filp, char *buffer, size_t length,
                           loff_t *offset) {
  char *msg = "Hello panix!\n";
  size_t msg_len = strlen(msg);

  if (*offset != 0)
    return 0;

  if (length < msg_len)
    return -EINVAL;

  if (copy_to_user(buffer, msg, msg_len))
    return -EFAULT;

  *offset = msg_len;
  return msg_len;
}

static ssize_t device_write(struct file *filp, const char *buf, size_t len,
                            loff_t *off) {
  printk(KERN_ALERT "Sorry, this operation isn't supported.\n");
  return -EINVAL;
}

static struct file_operations fops = {.read = device_read,
                                      .write = device_write,
                                      .open = device_open,
                                      .release = device_release};

static int __init dev_char_init(void) {
  major_number = register_chrdev(0, "panix-char", &fops);

  if (major_number < 0) {
    printk(KERN_ALERT "Registering char device failed with %d\n", major_number);
    return major_number;
  }

  printk(KERN_INFO "I was assigned major number %d.\n", major_number);
  printk(KERN_INFO "Create device with: 'mknod /dev/panix-char c %d 0'.\n",
         major_number);
  return 0;
}

static void __exit dev_char_exit(void) {
  unregister_chrdev(major_number, "panix-char");
}

module_init(dev_char_init);
module_exit(dev_char_exit);
