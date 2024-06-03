#
#---------------------------------------------------------------------------------------
#
# $1 - Library
# $2 - Object
# $3 - Object Type - MODULE or SRVPGM
#
#
function bd_putObjectInBindDir () {
  # look for  .binddir entry
  od_rtnObjectText "$2.binddir"
  if [ -z "$s_od_rot" ]; then
    return
  fi
  local objBindDir=$s_od_rot
  checkObject $1 $2 'BNDIR'
  if [ -n ind_co ]; then
    bd_createBindDir $1 $objBindDir
  fi

  if [ -n "$objBindDir" ]; then
    bd_checkForObjectInBindDir $1 $objBindDir $2
    if [ -n "$ind_bd_cfmibd" ]; then
      bd_rmvObjectInBindDir "$1" "$objBindDir" "$2" "$3"
    fi
    bd_addObjectToBindDir "$1" "$objBindDir" "$2" "$3"
  fi
}
#
#---------------------------------------------------------------------------------------
#
# $1 - Library
# $2 - BndDir
# $3 - Object
#
# $ind_bd_cfmibd - Set to blank if module found.
#
function bd_checkForObjectInBindDir () { 
#
# Zero out output file
#
  > $wTempDirExpanded/$wBinddirDtaFileName
#
# Start of block
#echo $wBinddirSqlFileName
cat > $wTempDirExpanded/$wBinddirSqlFileName <<EOS_bd_checkForObjectInBindDirSQL
BEGIN
  FOR 
   SELECT
    * 
   FROM
     QSYS2.BINDING_DIRECTORY_INFO
   WHERE 
    BINDING_DIRECTORY_LIBRARY = UPPER('$1') AND
    BINDING_DIRECTORY         = UPPER('$2') AND
    ENTRY                     = UPPER('$3')
   DO
    CALL QSYS2.IFS_WRITE(
      PATH_NAME  => '$wTempDirExpanded/$wBinddirDtaFileName', 
      LINE       => 'FOUND',
      FILE_CCSID => 1208
    ); END FOR; END;
EOS_bd_checkForObjectInBindDirSQL

  local err=$(callSqlScript "$wTempDirExpanded/$wBinddirSqlFileName")
  if [ -s "$wTempDirExpanded/$wBinddirDtaFile" ]; then
    ind_bd_cfmibd=""
  else
    ind_bd_cfmibd="-1"
  fi
}
#
#---------------------------------------------------------------------------------------
#
# $1 - Library
# $2 - BndDir
# $3 - Object
# $4 - Object Type
#
function bd_rmvObjectInBindDir () {
#
# Zero out output file
#
  > $wTempDirExpanded/$wBinddirErrFileName

  cat > $wTempDirExpanded/$wBinddirSqlFileName <<EOS_bd_rmvModuleInBindDirSQL
CALL qsys2.qcmdexc('RMVBNDDIRE BNDDIR($1/$2) OBJ(($3 *$4))');
EOS_bd_rmvModuleInBindDirSQL
#
  local err=$(callSqlScript "$wTempDirExpanded/$wBinddirSqlFileName")
}
#
#---------------------------------------------------------------------------------------
#
# $1 - Library
# $2 - BndDir
# $3 - Object
# $4 - Object Type
#
function bd_addObjectToBindDir () {
#
# Zero out output file
#
  > $wTempDirExpanded/$wBinddirErrFileName

  cat > $wTempDirExpanded/$wBinddirSqlFileName <<EOS_bd_addObjectToBindDirSQL
CALL qsys2.qcmdexc('ADDBNDDIRE BNDDIR($1/$2) OBJ(($3 *$4))');
EOS_bd_addObjectToBindDirSQL
#
  local err=$(callSqlScript "$wTempDirExpanded/$wBinddirSqlFileName")
}
#
#---------------------------------------------------------------------------------------
#
# $1 - Library
# $2 - Object
# $3 - Object Type
#
# $ind_bd_cfmo - Set to blank if object found.
#
function bd_checkForObjectInBindDir () {
#
# Zero out output file
#
  > $wTempDirExpanded/$wBinddirDtaFileName
#
  cat > $wTempDirExpanded/$wBinddirSqlFileName <<EOS_bd_checkForObjectInBindDirSQL
BEGIN
  FOR 
   SELECT
    OBJNAME, 
    OBJTYPE 
   FROM
    TABLE (QSYS2.OBJECT_STATISTICS(UPPER('$1'),'$3','*ALLSIMPLE')) 
   WHERE 
    OBJNAME = UPPER('$2')
   DO
    CALL QSYS2.IFS_WRITE(
      PATH_NAME  => '$wTempDirExpanded/$wBinddirDtaFileName', 
      LINE       => 'FOUND',
      FILE_CCSID => 1208
    ); END FOR; END;
EOS_bd_checkForObjectInBindDirSQL
#
  local err=$(callSqlScript "$wTempDirExpanded/$wBinddirSqlFileName")
#
  if [ -s "$wTempDirExpanded/$wBinddirDtaFile" ]; then
    ind_bd_cfmo=""
    runLog "Object Found"
  else
    ind_bd_cfmo="-1"
    runLog "Object NOT Found"
  fi
}
#
#---------------------------------------------------------------------------------------
#
# $1 - Library
# $2 - BndDir
#
function bd_createBindDir () {
#
# Zero out output file
#
  > $wTempDirExpanded/$wBinddirErrFileName
  od_rtnObjectText "$2.crtbnddir"
  
  cat > $wTempDirExpanded/$wBinddirSqlFileName <<EOS_bd_addModuleInBindDirSQL
CALL qsys2.qcmdexc('CRTBNDDIR BNDDIR($1/$2) TEXT(''$s_od_rot'')');
EOS_bd_addModuleInBindDirSQL
#
  local err=$(callSqlScript "$wTempDirExpanded/$wBinddirSqlFileName")
  
  checkObject $1 $2 'BNDDIR'
  if [ -n "$ind_co" ]; then
    echo "BNDDIR not created. Check the text make sure ' is escaped:'' " #'
    runLog "BNDDIR not created. Check the text make sure ' is escaped:'' "
    exit
  fi
}
