#!/bin/sh

BSP_TOP_DIR=$PWD
OUTPUT_DIR=$BSP_TOP_DIR/output
ROOTFS_DIR=$BSP_TOP_DIR/output/rootfs
YAFFSTOOL_DIR=$BSP_TOP_DIR/yaffstool
TOOLCHAIN_DIR=$BSP_TOP_DIR/toolchain
BUSYBOX_DIR=$BSP_TOP_DIR/busybox

mkdir -p $ROOTFS_DIR
cd $ROOTFS_DIR

# make rootfs dirs
mkdir -p bin dev etc home lib mnt opt proc root sbin sys tmp usr var
mkdir -p etc/init.d etc/rc.d etc/sysconfig
mkdir -p usr/lib usr/bin usr/sbin
mkdir -p var/run var/lib var/log var/lock var/tmp
mkdir -p ftpd httpd

# make nodes
fakeroot mknod -m 600 dev/console c 5 1
fakeroot mknod -m 666 dev/null    c 1 3

# touch files
touch etc/inittab
touch etc/init.d/rcS
touch etc/fstab
touch etc/sysconfig/HOSTNAME
touch etc/passwd
touch etc/group
touch etc/shadow
touch etc/profile
touch etc/inetd.conf
touch etc/httpd.conf
touch etc/mdev.conf
touch etc/hotplug-in
touch etc/hotplug-out
touch etc/create_nanddisk
touch bin/mount_mass_storage
touch bin/umount_mass_storage

# change dirs & files mode
chmod 1777 tmp var/tmp
chmod a+x etc/inittab
chmod a+x etc/init.d/rcS
chmod 644 etc/passwd
chmod 644 etc/group
chmod 640 etc/shadow
chmod a+x etc/init.d/rcS
chmod a+x etc/hotplug-in
chmod a+x etc/hotplug-out
chmod a+x etc/create_nanddisk
chmod a+x bin/mount_mass_storage
chmod a+x bin/umount_mass_storage

# passwd & group & shadow
echo "root:x:0:0:root:/root:/bin/ash"    > etc/passwd
echo "root:x:0:root"                     > etc/group
echo "root:YVMFuiEJMJR6k:0:0:99999:7:::" > etc/shadow

# inittab
echo "::sysinit:/etc/init.d/rcS"         > etc/inittab
echo "::askfirst:-/bin/sh"              >> etc/inittab
echo "::ctrlaltdel:/sbin/reboot"        >> etc/inittab
echo "::shutdown:/bin/umount -a -r"     >> etc/inittab

# fstab
echo "proc  /proc proc  defaults 0 0"    > etc/fstab
echo "none  /tmp  ramfs defaults 0 0"   >> etc/fstab
echo "mdev  /dev  ramfs defaults 0 0"   >> etc/fstab
echo "sysfs /sys  sysfs defaults 0 0"   >> etc/fstab

# HOSTNAME
echo "mini2440" > etc/sysconfig/HOSTNAME

# /etc/init.d/rcS
echo "#!/bin/sh"                                       > etc/init.d/rcS
echo "PATH=/sbin:/bin:/usr/sbin:/usr/bin"             >> etc/init.d/rcS
echo "runlevel=S"                                     >> etc/init.d/rcS
echo "prevlevel=N"                                    >> etc/init.d/rcS
echo "umask 022"                                      >> etc/init.d/rcS
echo "export PATH runlevel prevlevel"                 >> etc/init.d/rcS
echo ""                                               >> etc/init.d/rcS
echo "mount -a"                                       >> etc/init.d/rcS
echo "echo /sbin/mdev>/proc/sys/kernel/hotplug"       >> etc/init.d/rcS
echo "mdev -s"                                        >> etc/init.d/rcS
echo ""                                               >> etc/init.d/rcS
echo "/bin/hostname -F /etc/sysconfig/HOSTNAME"       >> etc/init.d/rcS
echo "/sbin/ifconfig lo 127.0.0.1"                    >> etc/init.d/rcS
echo "/sbin/ifconfig eth0 192.168.127.168"            >> etc/init.d/rcS
echo "/sbin/route add default gw 192.168.127.1"       >> etc/init.d/rcS
echo "mkdir /dev/pts"                                 >> etc/init.d/rcS
echo "/bin/mknod /dev/pts/0 c 136 0"                  >> etc/init.d/rcS
echo "/bin/mknod /dev/pts/1 c 136 1"                  >> etc/init.d/rcS
echo "/bin/mknod /dev/pts/2 c 136 2"                  >> etc/init.d/rcS
echo "/bin/mknod /dev/pts/3 c 136 3"                  >> etc/init.d/rcS
echo "/bin/mknod /dev/pts/4 c 136 4"                  >> etc/init.d/rcS
echo "/bin/mknod /dev/pts/5 c 136 5"                  >> etc/init.d/rcS
echo "/bin/mount -t devpts devpts /dev/pts"           >> etc/init.d/rcS
echo "/usr/sbin/telnetd"                              >> etc/init.d/rcS
echo "/usr/sbin/inetd"                                >> etc/init.d/rcS
echo "/usr/sbin/httpd -c /etc/httpd.conf -h /httpd"   >> etc/init.d/rcS
echo "sh /etc/create_nanddisk"                        >> etc/init.d/rcS

# /etc/profile
echo "# Ash profile"                                   > etc/profile
echo "# vim: syntax=sh"                               >> etc/profile
echo "# No core files by default"                     >> etc/profile
echo "ulimit -S -c 0 > /dev/null 2>&1"                >> etc/profile
echo "USER=\"\`id -un\`\""                            >> etc/profile
echo "LOGNAME=\$USER"                                 >> etc/profile
echo "PS1='[\\u@\\h:\\W]\\$ '"                        >> etc/profile
echo "PATH=\$PATH"                                    >> etc/profile
echo "HOSTNAME=\`/bin/hostname\`"                     >> etc/profile
echo "export USER LOGNAME PS1 PATH"                   >> etc/profile

# /etc/inetd.conf
echo "21 stream tcp nowait root ftpd ftpd -w /ftpd"    > etc/inetd.conf

# /etc/mdev.conf
echo "mmcblk[0-9]p[0-9] 0:0 666 @ /etc/hotplug-in"     > etc/mdev.conf
echo "mmcblk[0-9]       0:0 666 $ /etc/hotplug-out"   >> etc/mdev.conf
echo "sd[a-z][0-9]      0:0 666 @ /etc/hotplug-in"    >> etc/mdev.conf
echo "sd[a-z]           0:0 666 $ /etc/hotplug-out"   >> etc/mdev.conf

# /etc/hotplug-in
echo "#!/bin/sh"                                       > etc/hotplug-in
echo "case \$MDEV in"                                 >> etc/hotplug-in
echo "mmcblk[0-9]p[0-9])"                             >> etc/hotplug-in
echo "    mkdir -p /sdcard"                           >> etc/hotplug-in
echo "    mount -t vfat \$MDEV /sdcard"               >> etc/hotplug-in
echo "    ;;"                                         >> etc/hotplug-in
echo "sd[a-z][0-9])"                                  >> etc/hotplug-in
echo "    mkdir -p /usbdisk"                          >> etc/hotplug-in
echo "    mount -t vfat \$MDEV /usbdisk"              >> etc/hotplug-in
echo "    ;;"                                         >> etc/hotplug-in
echo "esac"                                           >> etc/hotplug-in

# /etc/hotplug-out
echo "#!/bin/sh"                                       > etc/hotplug-out
echo "case \$MDEV in"                                 >> etc/hotplug-out
echo "mmcblk[0-9])"                                   >> etc/hotplug-out
echo "    umount -lf /sdcard"                         >> etc/hotplug-out
echo "    rm -rf /sdcard"                             >> etc/hotplug-out
echo "    ;;"                                         >> etc/hotplug-out
echo "sd[a-z])"                                       >> etc/hotplug-out
echo "    umount -lf /usbdisk"                        >> etc/hotplug-out
echo "    rm -rf /usbdisk"                            >> etc/hotplug-out
echo "    ;;"                                         >> etc/hotplug-out
echo "esac"                                           >> etc/hotplug-out

# /etc/create_nanddisk
echo "#!/bin/sh"                                             > etc/create_nanddisk
echo "if [ ! -e nanddisk.img ]; then"                       >> etc/create_nanddisk
echo "    dd if=/dev/zero of=/nanddisk.img bs=1k count=16k" >> etc/create_nanddisk
echo "    mkfs.vfat /nanddisk.img"                          >> etc/create_nanddisk
echo "fi"                                                   >> etc/create_nanddisk
echo "mkdir -p /nanddisk"                                   >> etc/create_nanddisk
echo "mount -t vfat /nanddisk.img /nanddisk"                >> etc/create_nanddisk

# /bin/mount_mass_storage
echo "#!/bin/sh"                                       > bin/mount_mass_storage
echo "case \$1 in"                                    >> bin/mount_mass_storage
echo "sdcard)"                                        >> bin/mount_mass_storage
echo "    umount -lf /sdcard"                         >> bin/mount_mass_storage
echo "    rm -rf /sdcard"                             >> bin/mount_mass_storage
echo "    insmod /lib/modules/\`uname -r\`/g_mass_storage.ko file=/dev/mmcblk0 stall=0 removable=1" >> bin/mount_mass_storage
echo "    ;;"                                         >> bin/mount_mass_storage
echo "usbdisk)"                                       >> bin/mount_mass_storage
echo "    umount -lf /usbdisk"                        >> bin/mount_mass_storage
echo "    rm -rf /usbdisk"                            >> bin/mount_mass_storage
echo "    insmod /lib/modules/\`uname -r\`/g_mass_storage.ko file=/dev/sda stall=0 removable=1" >> bin/mount_mass_storage
echo "    ;;"                                         >> bin/mount_mass_storage
echo "nanddisk)"                                      >> bin/mount_mass_storage
echo "    umount -lf /nanddisk"                       >> bin/mount_mass_storage
echo "    rm -rf /nanddisk"                           >> bin/mount_mass_storage
echo "    insmod /lib/modules/\`uname -r\`/g_mass_storage.ko file=/nanddisk.img stall=0 removable=1" >> bin/mount_mass_storage
echo "    ;;"                                         >> bin/mount_mass_storage
echo "esac"                                           >> bin/mount_mass_storage

# /bin/umount_mass_storage
echo "#!/bin/sh"                                       > bin/umount_mass_storage
echo "case \$1 in"                                    >> bin/umount_mass_storage
echo "sdcard)"                                        >> bin/umount_mass_storage
echo "    rmmod g_mass_storage"                       >> bin/umount_mass_storage
echo "    mkdir -p /sdcard"                           >> bin/umount_mass_storage
echo "    mount -t vfat /dev/mmcblk0p1 /sdcard"       >> bin/umount_mass_storage
echo "    ;;"                                         >> bin/umount_mass_storage
echo "usbdisk)"                                       >> bin/umount_mass_storage
echo "    rmmod g_mass_storage"                       >> bin/umount_mass_storage
echo "    mkdir -p /usbdisk"                          >> bin/umount_mass_storage
echo "    mount -t vfat /dev/sda1 /usbdisk"           >> bin/umount_mass_storage
echo "    ;;"                                         >> bin/umount_mass_storage
echo "nanddisk)"                                      >> bin/umount_mass_storage
echo "    rmmod g_mass_storage"                       >> bin/umount_mass_storage
echo "    mkdir -p /nanddisk"                         >> bin/umount_mass_storage
echo "    mount -t vfat /nanddisk.img /nanddisk"      >> bin/umount_mass_storage
echo "    ;;"                                         >> bin/umount_mass_storage
echo "esac"                                           >> bin/umount_mass_storage

# /httpd/index.html
echo "<html>"                                          > httpd/index.html
echo "<head><title>mini2440 httpd</title></head>"     >> httpd/index.html
echo "<body>"                                         >> httpd/index.html
echo "<h1>mini2440 httpd</h1>"                        >> httpd/index.html
echo "<p>This page is from mini2440 httpd server.</p>">> httpd/index.html
echo "</body>"                                        >> httpd/index.html
echo "</html>"                                        >> httpd/index.html

cp $TOOLCHAIN_DIR/arm-mini2440-linux-gnueabi/sysroot/lib/ld-linux.so.3   lib
cp $TOOLCHAIN_DIR/arm-mini2440-linux-gnueabi/sysroot/lib/libc.so.6       lib
cp $TOOLCHAIN_DIR/arm-mini2440-linux-gnueabi/sysroot/lib/libm.so.6       lib
cp $TOOLCHAIN_DIR/arm-mini2440-linux-gnueabi/sysroot/lib/libgcc_s.so.1   lib
cp $TOOLCHAIN_DIR/arm-mini2440-linux-gnueabi/sysroot/lib/librt.so.1      lib
cp $TOOLCHAIN_DIR/arm-mini2440-linux-gnueabi/sysroot/lib/libdl.so.2      lib
cp $TOOLCHAIN_DIR/arm-mini2440-linux-gnueabi/sysroot/lib/libpthread.so.0 lib

mkdir -p usr/share/udhcpc
cp $BUSYBOX_DIR/examples/udhcp/simple.script usr/share/udhcpc/default.script
chmod a+x usr/share/udhcpc/default.script

cd $BSP_TOP_DIR
fakeroot $YAFFSTOOL_DIR/mkyaffs2image-128M output/rootfs output/rootfs.yaffs

