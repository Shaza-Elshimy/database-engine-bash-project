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
   echo "create DBMS ..."
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
            echo "DBMS is created."
        fi
        while true
        do
            read  -r -p "Enter your DB Name:" dbName

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
                        echo -e "$Green DB is Created ...... $Reset"
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
            echo "DBMS is created."
            continue
        fi

        dbs=$(ls -F ./DBMS | grep '/' | tr -d '/')
        if [[ -z $dbs ]] ;then
          echo "NO Databases Found..."
        else
          echo "-------List Of Databases--------"
          ls -F ./DBMS | grep '/' | tr -d '/'
          echo "--------------------------------"
        fi
        sleep 5
        break
    ;;
    3 | "ConnectDB" )
        echo -e "$Green Your Choise is ConnectDB....... $Reset"

        if [[ ! -d ./DBMS ]] ;then 
           echo -e " $Red DBMS not Found , i will create one $Reset"
            mkdir ./DBMS
            sleep 1
            echo "DBMS is created."
        fi
        while true
        do
            read  -r -p "Enter your DB Name to connect:" dbName

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
                    export PS3="db_project>>"
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
            read  -r -p "Enter your DB Name to remove:" dbName

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
                    echo "Wait remove $dbName ......"
                    rm -r ./DBMS/$dbName
                    sleep 1
                    
                    if (($? == 0));then 
                        echo " DB removed successfully ......"
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
    echo " Your Choice is Exit ..."
    read -p ", Are you sure : y / n :" sure
    if [[ $sure == "y" ]] ;then
    echo "Program Exited"
      exit
    elif [[ $sure == "n" ]] ;then
      echo "program still running...."
      break
    else
      echo "please choose y or n"
    fi
    # 
    break
    ;;
    *)
        echo "Your Choise Not Found ......." 
        #
        break
    ;;
    esac 
done
sleep 2
done