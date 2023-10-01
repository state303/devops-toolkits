#!/bin/sh

# check privilege
if [ "$(id -u)" -ne 0 ] ; then
	echo "Please run as root"
	exit 1
fi


# check argument count
if [ "$#" -ne 2 ] ; then
	echo "Requires both numeric vmid and release (i.e. jammy)" >&2
	echo "Example: ./cloudimage.sh 5000 focal" >&2
	exit 1
fi


# check vmid is numerical value
output=`echo "$1" | grep -o "[0-9]\+"`
if [ "$output" -ne $1 ]; then
  	echo "vmid must be a numeric value!" >&2
	exit 1
fi


# check requested release train
allowed="focal jammy bionic kinetic lunar mantic minimal xenial"
if ! [ "${allowed#*"$2"}" != "$allowed" ]; then
	echo "unsupported release: $2"
	echo "please try among following releases: $allowed"
	exit 1
fi


# download file
filename="$2-server-cloudimg-amd64.img"
baseurl="https://cloud-images.ubuntu.com/$2/current"
src="$baseurl/$filename"
echo `curl -LO $src $filename`

# create new vm with given vmid
qm create "$1" --memory 2048 --name "ubuntu-cloud-$2" --net0 virtio,bridge=vmbr0


# import server image
qm importdisk "$1" "$filename" local-lvm


# remove image
rm -f "$filename"


# attach as scsi drive
qm set "$1" --scsihw virtio-scsi-pci --scsi0 "local-lvm:vm-$1-disk-0"


# announce cloudinit drive for IDE 2
qm set "$1" --ide2 local-lvm:cloudinit


# attach new drive as a bootdisk 
qm set "$1" --boot c --bootdisk scsi0


# attach vga to support console
qm set "$1" --serial0 socket --vga serial0

echo "done!"