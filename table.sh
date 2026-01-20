
#!/usr/bin/bash

LC_COLLATE=C 
shopt -s extglob 

Reset="\033[0m"
Red="\033[31m"
Green="\033[32m"
Yellow="\033[33m"
Blue="\033[34m"
Cyan="\033[36m"

create_table() {

    dbName="$1"
    DB_PATH="./DBMS/$dbName"

   
    if [ ! -d "$DB_PATH" ]; then
        echo -e "$Red Database not found $Reset"
        return
    fi


    while true; do
        echo -ne "${Cyan} Enter Table Name (Enter to cancel): ${Reset}" 
         read -r tableName

        if [ -z "$tableName" ]; then
            echo -e "$Red Cancelled $Reset"
            return
        fi

        case $tableName in
            *" "*|[0-9]*|*[!a-zA-Z0-9_]*)
                echo -e "$Red Invalid table name $Reset"
                ;;
            *)
                if [ -f "$DB_PATH/$tableName.meta" ]; then
                    echo -e "$Red Table already exists $Reset"
                else
                    break
                fi
                ;;
        esac
    done

    
    while true; do
      echo -ne "${Cyan} Enter number of columns: ${Reset}" 
         read -r cols

        if [ -z "$cols" ]; then
            echo -e "$Red Cancelled $Reset"
            return
        fi

        if [[ $cols =~ ^[1-9][0-9]*$ ]]; then
            break
        else
            echo -e "$Red Invalid number $Reset"
        fi
    done

   
    touch "$DB_PATH/$tableName.meta"
    touch "$DB_PATH/$tableName.data"
    > "$DB_PATH/$tableName.meta"

   
    while true; do
      echo -ne  "${Cyan} Enter PK column number (1-$cols): ${Reset}"
       read -r  pk

        if [[ $pk =~ ^[1-9][0-9]*$ ]] && [ "$pk" -ge 1 ] && [ "$pk" -le "$cols" ]; then
            break
        else
            echo -e "$Red Invalid PK $Reset"
        fi
    done

  
    for (( i=1; i<=cols; i++ )); do

        
        while true; do
           echo -ne  " ${Cyan} Column $i name: ${Reset}" 
          read -r colName

            if [ -z "$colName" ]; then
                echo -e "$Red Cancelled $Reset "
                rm -f "$DB_PATH/$tableName.meta" "$DB_PATH/$tableName.data"
                return
            fi

            case $colName in
                *" "*|[0-9]*|*[!a-zA-Z0-9_]*)
                    echo -e "$Red Invalid column name $Reset"
                    ;;
                *)
                    if grep -q "^$colName:" "$DB_PATH/$tableName.meta"; then
                        echo -e "$Red Duplicate column name $Reset"
                    else
                        break
                    fi
                    ;;
            esac
        done

      
        while true; do
            echo -ne "${Cyan} Column $i type (int/string): ${Reset}" 
           read -r colType

            if [ "$colType" = "int" ] || [ "$colType" = "string" ]; then
                break
            else
                echo -e "$Red Invalid type $Reset"
            fi
        done

        # write meta
        if [ "$i" -eq "$pk" ]; then
            echo "$colName:$colType:PK" >> "$DB_PATH/$tableName.meta"
        else
            echo "$colName:$colType" >> "$DB_PATH/$tableName.meta"
        fi
    done

    echo -e "$Green Table '$tableName' created successfully $Reset"
}





list_tables () {

    local dbName="$1"
    local DB_PATH="./DBMS/$dbName"

    if [[ ! -d "$DB_PATH" ]]; then
        echo -e "$Red Error: Database '$dbName' does not exist. $Reset"
        read -p "Press Enter to continue..."
        return
    fi
    echo -e "$Cyan -----------------------------$Reset"
    echo -e "$Green Tables in database '$dbName': $Reset"
    echo -e "$Cyan -----------------------------$Reset"


    for file in "$DB_PATH"/*.meta; do
        if [[ -f "$file" ]]; then
          
            echo "  - $(basename "$file" .meta)"
           
            else 
            echo "  No tables found."

        fi
    done

   echo -ne "$Cyan Press Enter to return to Table Menu... $Reset"
    read -r 
}



drop_table() {

    local dbName="$1"
    local DB_PATH="./DBMS/$dbName"

    if [[ ! -d "$DB_PATH" ]]; then
        echo -e "$Red Error: Database '$dbName' does not exist.$Reset "
        return
    fi

    while true; do
       echo -ne "${Cyan} Enter table name to drop: ${Reset}" 
        read -r tableName

        if [[ -z "$tableName" ]]; then
            echo -e "$Red Error: Table name cannot be empty.$Reset "
            continue
        fi

        if [[ ! -f "$DB_PATH/${tableName}.meta" ]]; then
            echo -e "$Red Error: Table '$tableName' does not exist.$Reset "
            continue
        fi

        break
    done

        echo -ne "${Yellow} Are you sure you want to drop table '$tableName'? (y/n): ${Reset}" 
    read -r confirmation

    if [[ "$confirmation" == "y" ]]; then
        rm -f "$DB_PATH/${tableName}.meta"
        rm -f "$DB_PATH/${tableName}.data"
        echo -e "$Green Table '$tableName' dropped successfully. $Reset"
    else
        echo -e "$Red Drop table operation cancelled. $Reset"
    fi
}


insert_into_table() {

    local dbName="$1"
    local DB_PATH="./DBMS/$dbName"
    local tableName record=""

while true; do
     echo -ne "${Cyan}Enter table name (Enter to cancel): ${Reset}" 
         read -r tableName

        if [[ -z "$tableName" ]]; then
            echo -e "$Red Cancelled $Reset"
            return
        fi

        if [[ ! -f "$DB_PATH/$tableName.meta" ]]; then
            echo -e "$Red Table not found, try again $Reset"
            continue
        fi

        if [[ ! -s "$DB_PATH/$tableName.meta" ]]; then
            echo -e "$Red Invalid table (no columns) $Reset"
            continue
        fi


    echo "Enter values:"

    exec 3< "$DB_PATH/$tableName.meta"

    while IFS=: read -r colName colType colPK <&3
    do
        while true; do

         
            if [[ "$colPK" == "PK" ]]; then
                read -p "$colName ($colType, PK): " value
            else
                read -p "$colName ($colType): " value
            fi

         
            if [[ -z "$value" ]]; then
                echo -e "$Red Value required $Reset"
                continue
            fi

        
            if [[ "$colType" == "int" && ! "$value" =~ ^[0-9]+$ ]]; then
                echo -e "$Red Invalid input: must be integer $Reset"
                continue
            fi

          
            if [[ "$colPK" == "PK" ]]; then
                if cut -d':' -f1 "$DB_PATH/$tableName.data" | grep -qx "$value"; then
                    echo -e "$Red Primary key must be unique $Reset"
                    continue
                fi
            fi

            break
        done

        record="${record:+$record:}$value"
    done

    exec 3<&-

    [[ -z "$record" ]] && echo -e "$Red Insert failed $Reset" && return

    echo "$record" >> "$DB_PATH/$tableName.data"
    echo -e "$Green Record inserted successfully $Reset"
done
}

print_headers(){
  awk -F: 'BEGIN{ORS=":"} {print $1} END{print ""}' "$DB_PATH/$tableName.meta"
}





select_from_table() {

    local dbName="$1"
    local DB_PATH="./DBMS/$dbName"
    local tableName
    
    
    while true; do
           echo -ne "${Cyan}Enter table name (Enter to cancel): ${Reset}"
         read -r tableName

        if [[ -z "$tableName" ]]; then
            echo -e  "$Red Cancelled $Reset"
            return
        fi

        if [[ ! -f "$DB_PATH/$tableName.meta" ]]; then
            echo -e "$Red Table not found, try again $Reset"
            continue
        fi

        if [[ ! -s "$DB_PATH/$tableName.meta" ]]; then
            echo -e "$Red Invalid table (no columns) $Reset"
            continue
        fi



    while true 
    do
    echo "1) Select all"
    echo "2) Select by PK"
    echo "3) Select with condition (column=value)"
    echo "4) Select column by name"
    echo -ne "${Cyan}Choose option(Enter to cancel): ${Reset}" 
     read -r option

    if [[ -z "$option" ]] ; then
    echo -e "$Red Cancelled..$Reset"
    return
    fi

    case $option in

        1)
            echo "----------------------------"
            print_headers "$DB_PATH/$tableName.meta"
            echo
            echo "----------------------------"
            echo "All Records:"
            echo "-------------"
            cat "$DB_PATH/$tableName.data"
            echo "----------------------------"
            ;;

        2)
           
            pkIndex=$(awk -F: '$3=="PK" {print NR; exit}' "$DB_PATH/$tableName.meta")

            if [[ -z "$pkIndex" ]]; then
                echo -e "$Red No PK defined $Reset"
                return
            fi

            while true
            do
               echo -ne  "${Cyan} Enter PK value (Enter to cancel): ${Reset}"
                read -r pkValue

                if [[ -z "$pkValue" ]] ; then
                  echo -e "$Red Cancelled $Reset"
                  break
                fi
                

                result=$(awk -F: -v idx="$pkIndex" -v val="$pkValue" '
                    $idx==val {print}
                ' "$DB_PATH/$tableName.data")

                if [[ -z "$result" ]] ; then 
                   echo -e "$Red No record found $Reset"
                else
                    echo "----------------------------------"
                    print_headers "$DB_PATH/$tableName.meta"
                    echo
                    echo "----------------------------------"
                    echo "$result"
                    echo "----------------------------------"
                    break
                fi
            done
            ;;
            

        3)
         while true; do
                   echo -ne  "${Cyan} Enter condition (column=value): ${Reset}"
                    read -r condition

                    col=$(echo "$condition" | cut -d'=' -f1)
                    val=$(echo "$condition" | cut -d'=' -f2)

                    colIndex=$(awk -F: -v col="$col" '$1==col {print NR; exit}' "$DB_PATH/$tableName.meta")

                    if [[ -z "$colIndex" ]]; then
                        echo -e "$Red Column not found $Reset-e "
                        break
                    fi


                    results=$(awk -F: -v idx="$colIndex" -v val="$val" '
                        $idx==val {print}
                    ' "$DB_PATH/$tableName.data")

                    echo "----------------------------------"
                    print_headers "$DB_PATH/$tableName.meta"
                    echo
                    echo "----------------------------------"
                    echo "$results"
                    echo "----------------------------------"

                    count=$(printf '%s' "$results" | wc -l)

                    done
                ;;
        4)

                while true; do
                echo -ne "${Cyan}Enter column name to select (Enter to cancel): ${Reset}" 
                     read -r  colName

                    if [[ -z "$colName" ]]; then
                        echo -e "$Red Cancelled $Reset"
                        break
                    fi

                    colIndex=$(awk -F: -v c="$colName" '$1==c {print NR; exit}' "$DB_PATH/$tableName.meta")

                    if [[ -z "$colIndex" ]]; then
                        echo -e "$Red Column not found $Reset"
                        continue
                    fi

                    echo "----------------------------"
                    echo "Column: $colName"
                    echo "----------------------------"

                    awk -F: -v idx="$colIndex" '{print $idx}' "$DB_PATH/$tableName.data"

                    echo "----------------------------"
                    break
                done
                ;;        
        

        *)
            echo -e "$Red Invalid option $Reset"
            ;;
    esac
    done
 done   

    read -p "Press Enter to return to Table Menu..."
}


delete_from_table() {

    local dbName="$1"
    local DB_PATH="./DBMS/$dbName"
    local tableName


    while true; do
       echo -ne "${Cyan} Enter table name (Enter to cancel): ${Reset}" 
       read -r  tableName

        if [[ -z "$tableName" ]]; then
            echo -e "$Red Cancelled  $Reset"
            return
        fi

        if [[ ! -f "$DB_PATH/$tableName.meta" ]]; then
            echo -e "$Red Table not found, try again $Reset"
            continue
        fi

        if [[ ! -s "$DB_PATH/$tableName.meta" ]]; then
            echo -e "$Red Invalid table (no columns) $Reset"
            continue
        fi

        break
    done

    while true; do
        echo "--------------------------------------"
        echo "1) Delete all records"
        echo "2) Delete by PK"
        echo "3) Delete with condition (column=value)"
        echo "--------------------------------------"
     echo -ne "${Cyan} Choose option (Enter to cancel): ${Reset}" 
         read -r option

        if [[ -z "$option" ]] ; then
            echo -e "$Red Cancelled $Reset"
            return
        fi

        case $option in

        1)
        while true
        do
            echo -ne "${Yellow} Are you sure you want to delete ALL records? (y/n): ${Reset}" 
            read -r confirm
            if [[ "$confirm" != "y" ]] ; then
                echo -e "$Red Cancelled $Reset"
                break
            fi

            > "$DB_PATH/$tableName.data"
            echo -e "$Green All records deleted $Reset"
            break
         done 
            ;;

        2)
            pkIndex=$(awk -F: '$3=="PK" {print NR; exit}' "$DB_PATH/$tableName.meta")

            if [[ -z "$pkIndex" ]] ; then
                echo -e "$Red No PK defined $Reset" 
                break
            fi

            while true
            do
               echo -ne "${Cyan} Enter PK value to delete: ${Reset}"
                 read -p pkValue
                if [[ -z "$pkValue" ]] ; then
                    echo -e "$Red Cancelled $Reset" 
                    break
                fi

                before=$(wc -l < "$DB_PATH/$tableName.data")

                awk -F: -v idx="$pkIndex" -v val="$pkValue" '
                    $idx!=val
                ' "$DB_PATH/$tableName.data" > "$DB_PATH/tmp.data"

                after=$(wc -l < "$DB_PATH/tmp.data")

                if [[ $before -eq $after ]]; then
                    echo -e "$Red No record found $Reset"
                    rm "$DB_PATH/tmp.data"
                    break
                else
                    mv "$DB_PATH/tmp.data" "$DB_PATH/$tableName.data"
                    echo -e "$Green Record deleted successfully $Reset"
                    break
                fi
            done
            ;;

        3)
        while true
        do
           echo -ne "${Cyan} Enter condition (column=value): ${Reset}"
            read -r condition

            col=$(echo "$condition" | cut -d'=' -f1)
            val=$(echo "$condition" | cut -d'=' -f2)

            colIndex=$(awk -F: -v col="$col" '$1==col {print NR; exit}' "$DB_PATH/$tableName.meta")

            if [[ -z "$colIndex" ]] ; then
                echo -e "$Red Column not found $Reset" 
                break
            fi

            before=$(wc -l < "$DB_PATH/$tableName.data")

            awk -F: -v idx="$colIndex" -v val="$val" '
                $idx!=val
            ' "$DB_PATH/$tableName.data" > "$DB_PATH/tmp.data"

            after=$(wc -l < "$DB_PATH/tmp.data")

            if [[ $before -eq $after ]]; then
                echo -e "$Red No records matched $Reset"
                rm "$DB_PATH/tmp.data"
                break
            else
                mv "$DB_PATH/tmp.data" "$DB_PATH/$tableName.data"
                echo -e "$Green Records deleted successfully $Reset"
                break
            fi
        done

            ;;

        *)
            echo -e "$Red Invalid option $Reset"
            ;;
        esac
    done
}


update_table() {

    local dbName="$1"
    local DB_PATH="./DBMS/$dbName"
    local tableName

    
    while true
    do
        echo -ne "${Cyan} Enter table name (Enter to cancel): ${Reset}" 
        read -r tableName

        if [[ -z "$tableName" ]] ; then
            echo -e "$Red Cancelled $Reset" 
            return
        fi

        if [[ ! -f "$DB_PATH/$tableName.meta" ]]  ;then
            echo -e "$Red Table not found $Reset" 
            continue
        fi

    while true
    do
        echo "--------------------------------------"
        echo "1) Update all records"
        echo "2) Update by PK"
        echo "3) Update with condition (column=value)"
        echo "Choose option (Enter to cancel):"
        echo "--------------------------------------"
        read option

        if [[ -z "$option" ]] ; then
            echo -e "$Red Cancelled $Reset" 
            break
        fi

        case $option in

        1)

       echo -ne  "${Cyan} Enter column name to update: ${Reset}" 
               read -r col

            colIndex=$(awk -F: -v c="$col" '$1==c {print NR}' "$DB_PATH/$tableName.meta")

            colPK=$(awk -F: -v c="$col" '$1==c {print $3}' "$DB_PATH/$tableName.meta")

            if [[ -z "$colIndex" ]] ; then 
                echo -e "$Red Column not found $Reset" 
                continue
            fi

            if [[ "$colPK" == "PK" ]] ; then
                echo -e "$Red Error: primary Key cannot be updated $Reset"
                continue
            fi

            ech0 -ne  "${Cyan} Enter new value: ${Reset}" 
           read -r newValue

            awk -F: -v OFS=":" -v idx="$colIndex" -v val="$newValue" '
            {
                $idx = val
                print
            }' "$DB_PATH/$tableName.data" > "$DB_PATH/tmp.data"

            mv "$DB_PATH/tmp.data" "$DB_PATH/$tableName.data"
            echo -e "$Green All records updated $Reset"
            ;;

        2)
            pkIndex=$(awk -F: '$3=="PK" {print NR}' "$DB_PATH/$tableName.meta")

            if [[ -z "$pkIndex" ]] ; then
                echo -e "$Red No PK defined $Reset" 
                continue
            fi

            
           echo -ne  "${Cyan }Enter PK value: ${Reset}" 
            read -r pkValue

            echo -ne "${Cyan} Enter column name to update: ${Reset}"
            read -r col
            colIndex=$(awk -F: -v c="$col" '$1==c {print NR}' "$DB_PATH/$tableName.meta")
            colPK=$(awk -F: -v c="$col" '$1==c {print $3}' "$DB_PATH/$tableName.meta")

            if [[ -z "$colIndex" ]] ; then
                echo -e "$Red Column not found $Reset" 
                continue
            fi
            
            if [[ "$colPK" == "PK" ]] ; then
                echo -e "$Red Error: primary Key cannot be updated $Reset"
                continue
            fi


          echo -ne  "${Cyan} Enter new value: ${Reset}"
             read -r newValue

            awk -F: -v OFS=":" \
                -v pkIdx="$pkIndex" -v pkVal="$pkValue" \
                -v uIdx="$colIndex" -v newVal="$newValue" '
            {
                if ($pkIdx == pkVal) {
                    $uIdx = newVal
                    found=1
                }
                print
            }
            END {
                if (!found) exit 1
            }
            ' "$DB_PATH/$tableName.data" > "$DB_PATH/tmp.data"

            if [[ $? -ne 0 ]]; then
                echo -e "$Red No record found $Reset"
                rm "$DB_PATH/tmp.data"
            else
                mv "$DB_PATH/tmp.data" "$DB_PATH/$tableName.data"
                echo -e "$Green Record updated successfully $Reset"
            fi
            ;;

        3)
            echo -ne "${Cyan}Enter condition (column=value): ${Reset}" 
           read -r condition
            condCol=$(echo "$condition" | cut -d '=' -f1)
            condVal=$(echo "$condition" | cut -d '=' -f2)

            condIndex=$(awk -F: -v c="$condCol" '$1==c {print NR}' "$DB_PATH/$tableName.meta")

            if [[ -z "$condIndex" ]] ; then  
                echo -e "$Red Condition column not found $Reset" &
                continue
            fi

            echo -ne "${Cyan} Enter column name to update: ${Reset}" 
            read -r col
            colIndex=$(awk -F: -v c="$col" '$1==c {print NR}' "$DB_PATH/$tableName.meta")

            if [[ -z "$colIndex" ]] ; then
                echo -e "$Red Update column not found $Reset" 
                continue
            fi

            if [[ "$updIndex" -eq "$pkIndex" ]] ; then 
                echo -e "$Red Eror:Promary key cannot be updated $Reset"
                break
            fi


             echo -ne "{$Cyan} Enter new value: ${Reset}" 
           read -r newValue

            awk -F: -v OFS=":" \
                -v cIdx="$condIndex" -v cVal="$condVal" \
                -v uIdx="$colIndex" -v newVal="$newValue" '
            {
                if ($cIdx == cVal) {
                    $uIdx = newVal
                    updated=1
                }
                print
            }
            END {
                if (!updated) exit 1
            }
            ' "$DB_PATH/$tableName.data" > "$DB_PATH/tmp.data"

            if [[ $? -ne 0 ]]; then
                echo -e "$Red No records matched condition $Reset"
                rm "$DB_PATH/tmp.data"
            else
                mv "$DB_PATH/tmp.data" "$DB_PATH/$tableName.data"
                echo -e "$Green Records updated successfully $Reset"
            fi
            ;;

        *)
            echo -e "$Red Invalid option $Reset"
            ;;
        esac
    done
    done

    read -p "Press Enter to return to Table Menu..."
}


table_menu () {

    local dbName="$1"

    while true
    do
        clear
        echo "=========== DB Menu ($dbName) ==========="

        options=(
            "CreateTable"
            "ListTables"
            "DropTable"
            "InsertIntoTable"
            "SelectFromTable"
            "DeleteFromTable"
            "UpdateTable"
            "BackToMainMenu"
        )

        select choice in "${options[@]}"
        do
            case $REPLY in

                1 | "CreateTable" )
                    echo -e "$Yellow Create Table $Reset"
                    create_table "$dbName"
                    break
                    ;;

                2 | "ListTables")
                    echo -e "$Yellow List Tables $Reset"
                    list_tables "$dbName"
                    break
                    ;;

                3 | "DropTable")
                    echo -e "$Yellow Drop Table $Reset"
                    drop_table "$dbName"
                    break
                    ;;

                4 | "InsertIntoTable")
                    echo -e "$Yellow Insert Into Table $Reset"
                    insert_into_table "$dbName"
                    break
                    ;;

                5 | "SelectFromTable")
                    echo -e "$Yellow Select From Table $Reset"
                    select_from_table "$dbName"
                    break
                    ;;

                6 | "DeleteFromTable")
                    echo -e "$Yellow Delete From Table $Reset"
                    delete_from_table "$dbName"
                    break
                    ;;

                7 | "UpdateTable")
                    echo -e "$Yellow Update Table $Reset"
                    update_table "$dbName"
                    break
                    ;;

                8 | "BackToMainMenu")
                    echo -e "$Yellow Returning to Main Menu... $Reset"
                    return
                    ;;

                *)
                    echo -e "$Red Invalid choice $Reset"
                    #
                    break
                    ;;
            esac
        done
         sleep 1
    done
}







