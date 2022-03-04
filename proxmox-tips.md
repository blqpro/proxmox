#proxmox startup command tips 

#allocate all disk space (of the main 1 disk ) to one storage pool
	lvremove /dev/pve/data
	lvresize -l +100%FREE /dev/pve/root
	resize2fs /dev/mapper/pve-root

#For laptop change sleep state when the lid is closed 
	nano /etc/systemd/logind.conf
		--> # Change these 2 lines to ignore 
		HandleLidSwitch=ignore
		HandleLidSwitchDocked=ignore

#Update container image (unlock more turnkey linux )
pveam update

#Some tips from internet 
#Add a usb storage as main storage
	https://nubcakes.net/index.php/2019/03/05/how-to-add-storage-to-proxmox/
