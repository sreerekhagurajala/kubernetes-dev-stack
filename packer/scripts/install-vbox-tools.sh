#!/bin/bash

case "$PACKER_BUILDER_TYPE" in
virtualbox-iso|virtualbox-ovf)
        mkdir /tmp/isomount
	mount -t iso9660 -o loop /home/vagrant/VBoxGuestAdditions.iso /tmp/isomount
	cd /tmp/isomount
	./VBoxLinuxAdditions.run --nox11 || true
	cd /tmp
	umount /tmp/isomount
	rm -rf /tmp/isomount
        rm -rf /home/vagrant/VBoxGuestAdditions.iso
        rm -rf /opt/parallels-tools.tar.gz
	patch /usr/src/vboxguest-5.1.2/vboxvideo/vbox_ttm.c /tmp/vboxvideo.patch
        /sbin/rcvboxadd setup
        rm -rf /tmp/vboxvideo.patch
	yum remove -y gcc bzip2 kernel-ml-devel kernel-ml-headers kernel-ml-tools-libs dkms perl selinux-policy-devel
	yum -y clean all
	;;

parallels-iso|parallels-pvm)
	mv /tmp/parallels-tools.tar.gz /opt/
	cd /opt/
	tar zxvf parallels-tools.tar.gz
        cd parallels-tools
        ./install --install-unattended
        yum remove -y gcc bzip2 kernel-ml-devel kernel-ml-headers kernel-ml-tools-libs dkms selinux-policy-devel perl
        yum -y clean all
        cd /opt/
	rm -rf parallels-tools/
    	;;

*)
    	echo "Unknown Packer Builder Type >>$PACKER_BUILDER_TYPE<< selected."
    	echo "Known are virtualbox-iso|virtualbox-ovf|parallels-iso|parallels-pvm."
    	;;
esac

