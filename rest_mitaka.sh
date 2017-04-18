#!/bin/bash 


function menu {
tput setaf 2
echo -e "**************************************  Options  ******************************************"
echo ""
echo -e "Chose option" 
tput setaf 7


		IFS=","
		OPTIONS_MAIN=("Swift","Cinder","Exit")
		select opt in $OPTIONS_MAIN; do
           if [ "$opt" = "Swift" ]; then
				OPTIONS_SWIFT=("Create container","Create object","Download object","Delete object","Delete container","Main menu")
				select opt in $OPTIONS_SWIFT; do
									if [ "$opt" == "Create container" ];
										then
											get_key && container_create				
		
									elif [ "$opt" == "Create object" ];
										then
											get_key && object_create
		
									elif [ "$opt" == "Download object" ];
										then	
											get_key && object_download
	
									elif [ "$opt" == "Delete object" ];
										then
											get_key && object_delete
		
									elif [ "$opt" == "Delete container" ];
										then
											get_key && container_delete
				
									elif [ "$opt" == "Main menu" ];
										then	
											menu
									else 
										echo -e "Wrong choice.Try again"

									fi
								done
           
		   elif [ "$opt" = "Cinder" ]; then
				echo -e "Cinder not implemented yet."
           
		   elif [ "$opt" = "Exit" ]; then
				exit
				
		   else
				echo -e "Wrong choice. Try again."
           fi
       done
	unset IFS
}

#$172 for devstack or $185 for OPNFV
function get_key {
curl -s "http://$cloud_ip:5000/v2.0/tokens" -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"auth": {"tenantName": "admin", "passwordCredentials": {"username": "admin", "password": "admin"}}}' > key.tmp
auth_key_tmp=$(grep -r key.tmp -e 'id' | awk {'print $8'})
auth_url_tmp=$(grep -r key.tmp -e 'AUTH' | awk {'print $172'})
auth_key=${auth_key_tmp:1:$(expr ${#auth_key_tmp} - 3)}
auth_url=${auth_url_tmp:1:$(expr ${#auth_url_tmp} - 5)} 
rm key.tmp
}
function show_key {
curl -s "http://$cloud_ip:5000/v2.0/tokens" -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"auth": {"tenantName": "admin", "passwordCredentials": {"username": "admin", "password": "admin"}}}' > key.tmp
auth_key_tmp=$(grep -r key.tmp -e 'id' | awk {'print $8'})
auth_url_tmp=$(grep -r key.tmp -e 'AUTH' | awk {'print $172'})
auth_key=${auth_key_tmp:1:$(expr ${#auth_key_tmp} - 3)}
auth_url=${auth_url_tmp:1:$(expr ${#auth_url_tmp} - 5)}
rm key.tmp
echo -e "\e[32mAuth_key is:      	 \e[39m"   $auth_key && echo -e "\e[32mSwift_auth_url is:	 \e[39m"	$auth_url 
}
function container_create {
echo ""
existing_containers=$(curl -s $auth_url/ -X GET -H "X-Auth-Token:$auth_key") && echo -e "\e[32mExisting containers:    \e[39m" && echo -e  $existing_containers && echo ""
echo -e "\e[32mInsert container name\e[39m:" && read container_name && curl -s $auth_url/$container_name -X PUT -H "X-Auth-Token:$auth_key" && echo ""
existing_containers=$(curl -s $auth_url/ -X GET -H "X-Auth-Token:$auth_key") && echo -e "\e[32mExisting containers:    \e[39m" && echo -e  $existing_containers && echo ""
echo -e "Container created"
}

function object_create {
echo ""
existing_containers=$(curl -s $auth_url/ -X GET -H "X-Auth-Token:$auth_key") && echo -e "\e[32mExisting containers:    \e[39m" && echo -e  $existing_containers && echo ""
existing_containers_tmp=$(echo $existing_containers | tr "\n" " ")  
IFS=" " && read -a existing_containers <<< "$existing_containers_tmp" && unset IFS
	for container_number in "${existing_containers[@]}";		do
			container_content=$(curl -s "$auth_url/$container_number" -X GET -H "X-Auth-Token:$auth_key")
			echo -e "\e[32mContent in\e[39m $container_number :" $container_content
		done
echo ""
echo -e "\e[32mInsert container name you wish to use:\e[39m"	&& read container_name && echo -e ""
echo -e "\e[32mInsert data name:\e[39m" && read data_name && echo -e ""


START=$(date +%s.%N)
curl -s $auth_url/$container_name/$data_name -X PUT -T $data_name -H "X-Auth-Token:$auth_key"
END=$(date +%s.%N)
TIME_DIFF=$(echo "$END - $START" | bc)

container_content=$(curl -s $auth_url/$container_name -X GET -H "X-Auth-Token:$auth_key")
echo $container_content && echo -e "\e[32mTransfer completed in \e[39m $TIME_DIFF " && echo -e ""
}

function object_download {
echo ""
existing_containers=$(curl -s $auth_url/ -X GET -H "X-Auth-Token:$auth_key") && echo -e "\e[32mExisting containers:    \e[39m" && echo -e $existing_containers | tr "\n" " " 
existing_containers_tmp=$(echo $existing_containers | tr "\n" " ")  
IFS=" " && read -a existing_containers <<< "$existing_containers_tmp" && unset IFS
echo -e ""
	for container_number in "${existing_containers[@]}";		do
			container_content=$(curl -s "$auth_url/$container_number" -X GET -H "X-Auth-Token:$auth_key")
			echo -e "Content in $container_number :" $container_content
		done
echo -e "\e[32mInsert container name from which you want to download:\e[39m" && read container_name
echo -e "\e[32mInsert object name you wish to download:\e[39m" && read object_name
#START_TIME=$SECONDS
typeset -F SECONDS=0
curl -s $auth_url/$container_name/$object_name -X GET -H "X-Auth-Token:$auth_key" && echo -e ""
#ELAPSED_TIME=$(($SECONDS - $START_TIME))
ls -l | grep $object_name && echo -e "\e[32mDownload completed in \e[39m$SECONDS" && echo -e ""
echo -e "Object downloaded"
}
function object_delete { 
echo ""
existing_containers=$(curl -s $auth_url/ -X GET -H "X-Auth-Token:$auth_key") && echo -e "\e[32mExisting containers:    \e[39m" && echo -e  $existing_containers && echo ""
existing_containers_tmp=$(echo $existing_containers | tr "\n" " ")  
IFS=" " && read -a existing_containers <<< "$existing_containers_tmp" && unset IFS
	for container_number in "${existing_containers[@]}";		do
			container_content=$(curl -s "$auth_url/$container_number" -X GET -H "X-Auth-Token:$auth_key")
			echo -e "Content in $container_number :" $container_content
		done
echo -e "\e[32mInsert container name from which you want to delete object:\e[39m" && read container_name
echo -e "\e[32mInsert object name you wish to delete\e[39m" && read object_name
curl -s $auth_url/$container_name/$object_name -X DELETE -H "X-Auth-Token:$auth_key" && echo -e ""
container_content=$(curl -s $auth_url/$container_name -X GET -H "X-Auth-Token:$auth_key")
echo $container_content && echo -e "Object deleted" && echo -e ""
echo -e "Object deleted"
}
function container_delete {
echo -e "\e[31mNote: You CAN NOT remove container that has objects in it,\e[39m"
echo -e "\e[31mif it's not empty clear it first using delete_object fucntion.\e[39m"
echo ""
existing_containers=$(curl -s $auth_url/ -X GET -H "X-Auth-Token:$auth_key") && echo -e "\e[32mExisting containers:    \e[39m" && echo -e  $existing_containers && echo ""
existing_containers_tmp=$(echo $existing_containers | tr "\n" " ")  
IFS=" " && read -a existing_containers <<< "$existing_containers_tmp" && unset IFS
	for container_number in "${existing_containers[@]}";		do
			container_content=$(curl -s "$auth_url/$container_number" -X GET -H "X-Auth-Token:$auth_key")
			echo -e "Content in $container_number :" $container_content
		done
echo -e "\e[32mInsert container name you wish to delete :\e[39m" && read container_name		
curl -s $auth_url/$container_name -X DELETE -H "X-Auth-Token:$auth_key" && echo ""
existing_containers=$(curl -s $auth_url/ -X GET -H "X-Auth-Token:$auth_key") && echo -e "\e[32mExisting containers:    \e[39m"		$existing_containers && echo ""
echo -e "Container deleted"
}

#Main
tput setaf 6
echo ""
echo -e "|-----------------------------------------------------|"
echo -e "|***  mitaka_rest.sh is a bash script capable of   ***|"
echo -e "|***  sending REST calls to OpenStack public IP    ***|"
echo -e "|***  based on devstack mitaka using keystone v2   ***|"
echo -e "|-----------------------------------------------------|"
echo -e "|***  Info: Before running the script verify what  ***|"
echo -e "|***  is the owner account of the swift project    ***|"
echo -e "|-----------------------------------------------------|"
echo ""
echo ""
tput setaf 2 
echo -e "Insert OpenStack IP address" 
tput setaf 7  
read cloud_ip
echo ""
show_key
echo ""
menu
