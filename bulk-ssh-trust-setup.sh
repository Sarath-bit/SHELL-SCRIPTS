#!/bin/bash
# prepared by Sarath kumar
#this is  distro: linux . bash specific
echo -e "\e[1;34m enter source server \e[0m"
cat >source
echo -e "\e[1;34m enter destination server \e[0m"
cat >destination
echo -e "\e[1;34m enter sourcefid \e[0m"
cat >sourcefid
echo -e "\e[1;34m enter destinationfid \e[0m"
cat >destinationfid
echo -e "\e[1;34m enter admin server \e[0m"
cat >admin
echo -e "\e[1;34m change number \e[0m"
cat >CHG
echo -e "\e[1;34m Enter Authorization line entry \e[0m"
cat >auth
source=`cat source`
destination=`cat destination`
destinationfid=`cat destinationfid`
sourcefid=`cat sourcefid`
admin=`cat admin`
CHG=`cat CHG`
ssh -x $source "cat /etc/redhat-release" > sversion
sversion=`cat sversion  | awk '{print $7}' | cut -d "." -f 1`
echo -e "\e[1;32m ------Source  version verified ----------- \e[0m"
echo -e "\e[1;32m ------started script---------------------- \e[0m"
if [ "$sversion" -ge "7" ]; then
    echo -e "\e[1;32m --- Source is RHEL 7 : $source ------------ \e[0m"
    echo "ls -ld /etc/ssh/keys/$sourcefid/id_rsa*" > checksourcekey.sh
    ssh -x $source /bin/bash <checksourcekey.sh > sourcekey7
    if [ -s sourcekey7 ]; then
		echo -e "\e[1;35m -----------Source Key exists---------- \e[0m"
		scp -pr $source:/etc/ssh/keys/$sourcefid/id_rsa*.pub  /tmp/ssh/
		cp  /tmp/ssh/id_rsa*.pub /tmp/ssh/$sourcefid@$source.open.pub
		for i in `cat destination`; do
			ssh -x $i "cat /etc/redhat-release" > dversion
			dversion=`cat dversion  | awk '{print $7}' | cut -d "." -f 1`
			if [[ "$dversion" -ge "7" ]]; then
				scp -pr /tmp/ssh/$sourcefid@$source.open.pub $i:/tmp/
				ssh -x $i "mkdir -p /var/tmp/keys_bkp.$CHG"
				ssh -x $i "cp -pr /etc/ssh/keys /var/tmp/keys_bkp.$CHG"
				ssh -x $i "mkdir -p /etc/ssh/keys/$destinationfid ; chmod 111 /etc/ssh/keys/$destinationfid"
				ssh -x $i "cat /tmp/$sourcefid@$source.open.pub >> /etc/ssh/keys/$destinationfid/authorized_keys"
				echo -e "\e[1;32m --------------------STATUS : keys copied to ID : $destinationfid SERVER : $i -------------- \e[0m"
				echo -e "********************************"
			else
				scp -pr /tmp/ssh/$sourcefid@$source.open.pub  $i:/tmp/
				ssh -x $i "ssh-keygen-g3 --import-public-key /tmp/$sourcefid@$source_open.pub /tmp/$sourcefid@$source.pub" 
				ssh -x $i "mkdir -p /var/tmp/keys_bkp.$CHG"
				ssh -x $i "cp -pr /etc/opt/SSHtectia/keys /var/tmp/keys_bkp.$CHG"
				ssh -x $i "mkdir -p /etc/opt/SSHtectia/keys/$destinationfid ; chmod 111 /etc/opt/SSHtectia/keys/$destinationfid"
				scp -pr /tmp/ssh/$sourcefid@$source.pub $i:/etc/opt/SSHtectia/keys/$destinationfid/
				ssh -x $i "chmod 444 /etc/opt/SSHtectia/keys/$destinationfid/$sourcefid@$source.pub"
				ssh -x $i "touch /etc/opt/SSHtectia/keys/$destinationfid/authorization "
				ssh -x $i "echo "Key $sourcefid@$source.pub" >> /etc/opt/SSHtectia/keys/$destinationfid/authorization "
				scp -pr /tmp/ssh/auth $i:/tmp/
				ssh -x $i "cat  /tmp/auth >> /etc/opt/SSHtectia/keys/$destinationfid/authorization "
				echo -e "\e[1;32m -----------------------STATUS : keys copied to ID : $destinationfid SERVER : $i -----------------\e[0m"
				echo -e "********************************"
			fi
		done	
    else
		echo -e "\e[1;31m ---------- Public key not exists on $source  ---------- \e[0m"
    fi
else
    echo -e "\e[1;33m **************source is rhel 6**************** \e[0m"
    echo "ls -ld /etc/opt/SSHtectia/keys/$sourcefid/id_rsa*" > checksourcekey.sh
    ssh -x $source /bin/bash <checksourcekey.sh > sourcekey6
    if [ -s sourcekey6 ]; then
		echo "**************Source Key exists***************"
		scp -pr $source:/etc/opt/SSHtectia/keys/$sourcefid/id_rsa*.pub  /tmp/ssh/
		cp  /tmp/ssh/id_rsa*.pub /tmp/ssh/$sourcefid@$source.pub
		for i in `cat destination`; do 
			ssh -x $i "cat /etc/redhat-release" > dversion
			dversion=`cat version  | awk '{print $7}' | cut -d "." -f 1`
			if [[ "$dversion" -ge "7" ]]; then
				scp -pr /tmp/ssh/$sourcefid@$source.pub  $i:/tmp/
				ssh -x $i "ssh-keygen -i -f  /tmp/$sourcefid@$source.pub > /tmp/$sourcefid@$source.open.pub"
				ssh -x $i "mkdir -p /var/tmp/keys_bkp.$CHG"
				ssh -x $i "cp -pr /etc/ssh/keys /var/tmp/keys_bkp.$CHG"
				ssh -x $i "mkdir -p /etc/ssh/keys/$destinationfid ; chmod 111 /etc/ssh/keys/$destinationfid"
				ssh -x $i "cat /tmp/$sourcefid@$source_open.pub >> /etc/ssh/keys/$destinationfid/authorized_keys"
				echo -e "\e[1;32m ------------STATUS : keys copied to ID : $destinationfid SERVER : $i ------------- \e[0m"
				echo -e "******************************"
			else
				ssh -x $i "mkdir -p /var/tmp/keys_bkp.$CHG"
				ssh -x $i "cp -pr /etc/opt/SSHtectia/keys /var/tmp/keys_bkp.$CHG"
				ssh -x $i "mkdir -p /etc/opt/SSHtectia/keys/$destinationfid ; chmod 111 /etc/opt/SSHtectia/keys/$destinationfid "
				scp -pr /tmp/ssh/$sourcefid@$source.pub $destination:/etc/opt/SSHtectia/keys/$destinationfid/
				ssh -x $i "chmod 444 /etc/opt/SSHtectia/keys/$destinationfid/$sourcefid@$source.pub"
				ssh -x $i "touch /etc/opt/SSHtectia/keys/$destinationfid/authorization"
				ssh -x $i "echo "Key $sourcefid@$source.pub" >> /etc/opt/SSHtectia/keys/$destinationfid/authorization "
				scp -pr /tmp/ssh/auth $i:/tmp/
				ssh -x $i "cat  /tmp/auth >> /etc/opt/SSHtectia/keys/$destinationfid/authorization "
				echo -e "\e[1;32m --------- STATUS : keys copied to ID : $destinationfid SERVER : $i --------- \e[0m"
				echo -e "**********************************"
			fi	
		done	
    else
		echo -e "\e[1;31m ---------- Public key not exists on $source  ---------- \e[0m"
    fi
fi
echo -e "\e[1;31m ************REMOVING TEMPORARY FILES**************** \e[0m"
rm -rf admin  auth  checksourcekey.sh  CHG  destination  destinationfid  source  sourcefid  sourcekey7 sversion dversion *pub
echo -e "\e[1;32m ************SCRIPT COMPLETED VERIFY THE LOGS**************** \e[0m"


