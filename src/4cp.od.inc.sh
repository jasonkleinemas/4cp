#
# This file is for reading the obj_desc.csv file
#
#---------------------------------------------------------------------------------------
#
# $1 - object
#
# $f_od_rol - List of objects LIB/OBJ1 LIB/OBJ2 ...
#
function od_rtnObjectList () {

  local ww

  od_rtnObjectText "$1.list"
  
  IFS=" "
  read -a ww <<< "$s_od_rot"
  for val in ${ww[@]}; do
    s_od_rol="$s_od_rol $oLibrary/$val"
  done
}
#
#---------------------------------------------------------------------------------------
#
# $1 - object with extention
#
# $s_od_rot - Text for the object
#
function od_rtnObjectText () {

  local ww

  s_od_rot=$(cat $wObjectDescriptionFile | grep "$1")
  IFS=","
  read -a ww <<< "$s_od_rot"
  s_od_rot=${ww[1]}
#  echo od_rtnObjectText $1 $s_od_rot
}
