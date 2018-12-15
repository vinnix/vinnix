## Initial copy

# https://forums.freebsd.org/threads/using-grub2-to-chainload-geli-encrypted-root-on-zfs-freebsd-10-1-rc2.48442/

```
menuentry 'FreeBSD' {
    set root=(hd0,gpt9)
    chainloader /boot/loader.efi
}
```



# https://forums.freebsd.org/threads/booting-freebsd-via-grub.60422/


# https://forums.freebsd.org/threads/grub2-efi-boot-problem.65123/
```
gpart add -t efi -s 300m /dev/<your_device>
newfs_msdos -F 32 -L efi /dev/<your_new_partition>
mount -t msdosfs /dev/<your_new_partition> /mnt
mkdir -pv /mnt/EFI/BOOT
cp -v /boot/boot1.efi /mnt/EFI/BOOT/BOOTX64.EFI
umount /mnt
```


# https://forums.freebsd.org/threads/error-while-installing-grub2-efi.60009/
```
umount /mnt/pend/boot
umount /mnt/pend

dd if=/boot/boot1.efifat of=/dev/da0p1

mount /mnt/pend
mount /mnt/pend/boot

grub-install --boot-directory=/rpool/boot --bootloader-id=grub --efi-directory=/mnt/efisys --no-nvram --target=x86_64-efi /dev/da0

```

# https://forums.freebsd.org/threads/fighting-with-grub2.58008/
```
menuentry "FreeBSD 11" {
   insmod ufs2
   insmod bsd
   set root=(hd0,gpt2)
   chainloader /boot/boot1.efi
}
```




# https://lists.freebsd.org/pipermail/freebsd-hackers/2015-August/048141.html
#--> https://lists.freebsd.org/pipermail/freebsd-hackers/2015-May/047754.html

```
Hi folks, hi Eric,

Using the patch from this post :

https://lists.freebsd.org/pipermail/freebsd-hackers/2015-June/047823.html

against -CURRENT (r286279), I've been able to boot my ZFS-root system, yeah!

For those interested, here are the steps needed to get a working system. This 
should be done on a live system to be able to operate freely on the hard disk.

First, create the partitions :
------------------------------

We will work on a single disk, detected as ada0.

# gpart create -s gpt ada0
# gpart add -s 800K -t efi ada0
# gpart add -t freebsd-zfs ada0
# gpart show
=>        34  3907029101  ada0  GPT  (1.8T)
          34        1600     1  efi  (800K)
        1634  3907027501     2  freebsd-zfs  (1.8T)

We use two partitions : the first one will host the loader and the second one, 
the zpool.

Create the zpool, ZFS and mount the root FS :
---------------------------------------------

# zpool create -f -m none -o altroot=/mnt root ada0p2
# zfs create root/ROOT
# zfs create root/ROOT/default
# zfs set mountpoint=/ root/ROOT/default
# zpool set bootfs=root/ROOT/default root
# zfs mount -a
# mkdir /mnt/dev
# mount -t devfs none /mnt/dev

Install the system :
--------------------

Now it is time to install the system within /mnt.

[ not detailed here, use your favourite method ]

You can then unmount and export the zpool.

# umount /mnt/dev
# zpool export root

Prepare the EFI partition :
---------------------------

We copy the (patched) loader.efi (*not* boot1.efi, which did not work for me) 
to efi/boot/BOOTx64.efi and set currdev within loader.rc :

# newfs_msdos ada0p1
# mount -t msdosfs /dev/ada0p1 /mnt
# mkdir -p /mnt/efi/boot/
# cp loader-zfs.efi /mnt/efi/boot/BOOTx64.efi
# mkdir -p /mnt/boot
# cat > /mnt/boot/loader.rc << EOF
unload
set currdev=zfs:root/ROOT/default:
load boot/kernel/kernel
load boot/kernel/zfs.ko
autoboot
EOF
# (cd /mnt && find .)
.
./efi
./efi/boot
./efi/boot/BOOTx64.efi
./boot
./boot/loader.rc
# umount /mnt

Now, reboot and enjoy you new system :)

Pushing the limits :
--------------------

Using this method, it is even possible to get a system bootable from UEFI *or* 
legacy BIOS.

Just insert a freebsd-boot (64K) partition between the efi and freebsd-zfs 
ones and install the pmbr + gptzfsboot loaders :

# gpart bootcode -b /mnt/boot/pmbr -p /mnt/boot/gptzfsboot -i 2 ada0

Finally, modify the /boot/loader.conf file within the ZFS root filesystem 
(mounted on /mnt) :

# cat >> /mnt/boot/loader.conf << EOF
zfs_load="YES"
vfs.root.mountfrom="zfs:root/ROOT/default"
EOF

Now, you can reboot either from BIOS or UEFI, the system will handle both.

Given the following partition scheme :

1  efi  (800K)
2  freebsd-boot  (64K)
3  freebsd-zfs  (1.8T)

The boot process will use the following paths :

Boot from BIOS -> MBR (pmbr) -> 2 (gptboot) -> 3 (loader) -> 3 (kernel) -> zfs 
root mounted
Boot from UEFI -> 1 (BOOTx64.efi, a.k.a patched loader.efi) -> 3 (kernel) -> 
zfs root mounted

Eric, thanks for your great work, I hope your patch will be committed soon :)

Regards,

```

# https://www.freebsd.org/cgi/man.cgi?query=uefi&sektion=&manpath=freebsd-release-ports
