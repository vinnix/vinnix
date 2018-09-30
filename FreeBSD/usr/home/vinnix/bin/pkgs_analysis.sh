#!/usr/bin/env bash


function analyze () {
    echo "$1"
    eval "$1" | while IFS= read -r p;    
    do
	# package="$(echo -e ${p} | tr -d '[:space:]' | nawk '{$1=$1};1'  )"   
	# package="$(echo -e "${p}" | tr -d '\040\011\012\015')"
	# package=${p##*( )}
	package="$(echo -e ${p} | tr -d '[:space:]' )"   
	depends_on_qtd=$(pkg info -d ${package} | grep -v ":" | wc -l)
	required_by_qtd=$(pkg info -r ${package} | grep -v ":" | wc -l)
	printf "%-5s dependencies has %-50s and %-5s that requirest it.\n" "${depends_on_qtd}" "${p}" "${required_by_qtd}"
    done
}


run_leaf="0"
run_autoremove="0"

while getopts ":l :a" opt; do
  case $opt in
    l)
      echo "-l for leafs was triggered. remembering it" >&2
      run_leaf="1"
      ;;
    a)
      echo "-a for autoremove was triggered. remembering it" >&2
      run_autoremove="1"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      echo " "
      echo " Valid options:"
      echo " "
      echo "   -l for analyze leaf" >&2
      echo "   -a for analyze autoremove" >&2
      echo " "
      exit
      ;;
  esac
done


if [ "$run_leaf" == "1" ];
then
    echo "-----------------------------------------------------------------------------------------"
    echo "-- Analyzing leafs"
    echo "-----------------------------------------------------------------------------------------"
    leaf_cmd="pkg leaf"
    analyze "${leaf_cmd}"
fi

if [ "$run_autoremove" == "1" ];
then
    echo "-----------------------------------------------------------------------------------------"
    echo "-- Analyzing autoremove" 
    echo "-----------------------------------------------------------------------------------------"
    remove_cmd='pkg autoremove -n | sort | uniq | egrep -v "(Checking int|Deinstallation has|Installed packages|Number of|The ope|^ |^$)"'
    analyze "${remove_cmd}"
fi

