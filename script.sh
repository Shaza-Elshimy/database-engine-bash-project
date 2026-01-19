#!/usr/bin/bash



LC_COLLATE=C 
shopt -s extglob 
export PS3="db_project>>"
Reset="\033[0m"
Red="\033[31m"
Green="\033[32m"
Yellow="\033[33m"
Blue="\033[34m"
Cyan="\033[36m"

source ./table.sh


if [[ ! -d ./DBMS ]]; then
   echo "$Green create DBMS ... $Reset"
   mkdir ./DBMS
   sleep 1
fi

while true
do
clear
echo "==================DBMS Main Menu================="
mainMenu=("CreateDB" "ListAllDB" "ConnectDB" "RemoveDB" "Exit" )
select choice in  ${mainMenu[@]}
do 
    case $REPLY in 
    1 | "CreateDB" ) 
        echo -e " $Blue Your Choise is CreateDB ....... $Reset"

        if [[ ! -d ./DBMS ]] ;then 
           echo -e " $Red DBMS not Found , i will create one $Reset"
            mkdir ./DBMS
            sleep 1
            echo "$Green DBMS is created. $Reset"
        fi
        while true
        do
             echo -ne "${Cyan} Enter your DB Name: ${Reset}"
            read  -r dbName

            case  $dbName in
            "")
            echo -e "$Red Error : Name of DB Can't be empty $Reset"
            ;;
            *" "*)
            echo -e "$Red Error : Name of DB Can't be contian space $Reset"
            ;;
            [0-9]*)
            echo -e "$Red Error : Name of DB Can't Start Numbers $Reset"
            ;;
            +([a-zA-Z0-9_]))

                if [[ -d ./DBMS/$dbName ]];then 
                    echo -e "$Red Error : Name of DB Already Exist$Reset"  
                else 
                    echo -e "$Yellow Wait Create DB ...... $Reset"
                    mkdir ./DBMS/$dbName
                    sleep 1

                    if (($? == 0));then 
                        echo -e "$Green DB is Created  $Reset"
                    else 
                        echo -e "$Red Error : DB not created $Reset"
                    fi 
                    break
                fi 
                # 
                break
            ;;
            *)
            echo -e "$Red Error 104: Name of Folder Contains Special Character : $Reset"  
            ;;
            esac
        done
        
    ;;
    2 | "ListAllDB" )
        echo -e "$Blue Your Choise is ListAllDB ....... $Reset"

        if [[ ! -d ./DBMS ]] ;then 
           echo -e "$Red DBMS not Found , i will create one $Reset"
            mkdir ./DBMS
            sleep 1
            echo "$Green DBMS is created. $Reset"
            continue
        fi

        dbs=$(ls -F ./DBMS | grep '/' | tr -d '/')
        if [[ -z $dbs ]] ;then
          echo "$Red NO Databases Found... $Reset"
        else
          echo -e "$Cyan -------List Of Databases-------- $Reset"
          ls -F ./DBMS | grep '/' | tr -d '/'
          echo -e "$Cyan -------------------------------- $Reset"
        fi
        sleep 6
        break
    ;;
    3 | "ConnectDB" )
        echo -e "$Blue Your Choise is ConnectDB....... $Reset"

        if [[ ! -d ./DBMS ]] ;then 
           echo -e " $Red DBMS not Found , i will create one $Reset"
            mkdir ./DBMS
            sleep 1
            echo -e "$Green DBMS is created. $Reset"
        fi
        while true
        do
            echo -ne "${Cyan} Enter your DB Name to connect: ${Reset}"
             read -r  dbName

            case  $dbName in
            "")
            echo -e "$Red Error : Name of DB Can't be empty $Reset"
            ;;
            *" "*)
            echo -e "$Red Error : Name of DB Can't be contian space $Reset"
            ;;
            [0-9]*)
            echo -e "$Red Error : Name of DB Can't Start Numbers $Reset"
            ;;
            *[!a-zA-Z0-9_]* )
            echo -e "$Red Error 104: Name of Folder Contains Special Character : $Reset"  
            ;;
            *)
                if [[ -d ./DBMS/$dbName ]];then 
                    echo -e "$Yellow Wait connect to $dbName ...... $Reset"
            
                    export PS3="$dbName>>" 
                    table_menu  "$dbName" 
                    export PS3="$dbName>>"
                    sleep 1
                    break
                    if (($? == 0));then 
                        echo -e "$Green DB Connected successfully ......$Reset"
                    else
                        echo -e "$Red Error : DB connect failed $Reset"
                    fi

                else
                    echo -e "$Red  Error : DB Not Found $Reset"
                fi 
            ;;
            esac
        done
        # 
        break
    ;;
    4 | "RemoveDB")
        echo -e "$Blue Your Choise is RemoveDB....... $Reset"

        if [[ ! -d ./DBMS ]] ;then 
           echo -e " $Red DBMS not Found , i will create one $Reset"
            mkdir ./DBMS
            sleep 1
            echo -e "$Green DBMS is created. $Reset"
            continue
        fi
        while true
        do
          echo -ne "${Cyan}Enter your DB Name to remove: ${Reset}"
           read -r dbName


            case  $dbName in
            "")
            echo -e "$Red Error : Name of DB Can't be empty $Reset"
            ;;
            *" "*)
            echo -e "$Red Error : Name of DB Can't be contian space $Reset"
            ;;
            [0-9]*)
            echo -e "$Red Error : Name of DB Can't Start Numbers $Reset"
            ;;
            *[!a-zA-Z0-9_]* )
            echo -e "$Red Error 104: Name of Folder Contains Special Character  $Reset"  
            ;;
            *)
                if [[ -d ./DBMS/$dbName ]];then 
                    echo -e "$Yellow Wait remove $dbName ...... $Reset"
                    rm -r ./DBMS/$dbName
                    sleep 1
                    
                    if (($? == 0));then 
                        echo -e "$Green DB removed successfully .. $Reset"
                    else 
                        echo -e "$Red Error : DB remove failed $Reset"
                    fi 
                    break 

                else 
                    echo -e "$Red Error : DB Not Found $Reset"
                fi 
            ;;
            esac
        done
        # 
        break
    ;;
    5 | "Exit" )
    echo -e "$Blue Your Choice is Exit ... $Reset"
    echo -ne "${Yellow} Are you sure : y / n :${Reset} " 
    read -r sure
    if [[ $sure == "y" ]] ;then
    echo -e "$Green Program Exited $Reset"
      exit
    elif [[ $sure == "n" ]] ;then
      echo -e "$Cyan program still running.... $Reset"
      break
    else
      echo -e "$Yellow please choose y or n $Reset"
    fi
    # 
    break
    ;;
    *)
        echo -e "$Red Your Choise Not Found ! $Reset" 
        #
        break
    ;;
    esac 
done
sleep 2
done