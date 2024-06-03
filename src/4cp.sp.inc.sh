#
# This used when modules are compiled. Then linked to a service program.
#
#---------------------------------------------------------------------------------------
#
# $1 - Library
# $2 - Module
#
function sp_putModuleInServiceProgram () {
  log_startFunc "sp_putModuleInServiceProgram"
  local err
  # look for  .srvpgm entry
  od_rtnObjectText "$2.srvpgm"
  local spObjName=$s_od_rot
  if [ -z "$spObjName" ]; then
    return                         # No entry leave.
  fi
  checkObject $1 $2 'SRVPGM'
  if [ -n "$ind_co" ]; then
    err=$(sp_createServiceProgram $1 $2 "$spObjName")
    if [ -n "$err" ]; then
      echo "Failed to create Service program, Exiting."
      writeToLastRunLog "sp_putModuleInServiceProgram:sp_createServiceProgram:$err"
      exit
    fi
  else
    err=$(sp_checkModuleInServiceProgram $1 $2 $1 $2)
    if [ -z "$err" ]; then
    # found replace
      err=$(sp_updateModuleInServiceProgram $1 $2 $1 $2)
      #
      # How to check success?
      #
#      if [ -n "$err" ]; then
#        echo "Failed to replace Module in Service program, Exiting."
#        writeToLastRunLog "sp_putModuleInServiceProgram:sp_replaceModuleInServiceProgram:$err"
#        exit
#      fi
    else
    #
    # How to add new module
    #
    x=""
    fi 
  fi
  #check if dnddir set.
#  bd_putObjectInBindDir $1 $spObjName "SRVPGM"
}
#
#---------------------------------------------------------------------------------------
#
# $1 - Library
# $2 - Object
# $3 - Text
#
function sp_createServiceProgram () {
  log_startFunc "sp_createServiceProgram"
  local cmd="CRTSRVPGM MODULE($1/$2) SRVPGM($1/$2) TEXT(''$3'') EXPORT(*ALL) OPTION(*EVENTF)"
  
  cat > $wSrvPgmSqlFile <<EOS_sp_createServiceProgramSQL
CALL qsys2.qcmdexc('$cmd');
EOS_sp_createServiceProgramSQL
#
  local err=$(callSqlScript "$wSrvPgmSqlFile")
#
  checkObject $1 $2 'SRVPGM'
  if [ -n "$ind_co" ]; then
    echo "-1"
    writeToLastRunLog "sp_createServiceProgram:SQL commandFailed:$cmd"
  else
    echo ""
  fi
}
#
#---------------------------------------------------------------------------------------
#
# $1 - SrvPrg Library
# $2 - SrvPrg Name
# $3 - Module Library
# $4 - Module Name
#
function sp_checkModuleInServiceProgram () {
  log_startFunc "sp_checkModuleInServiceProgram"
  > $wSrvPgmDtaFile

  cat > $wSrvPgmSqlFile <<EOS_sp_checkModuleInServiceProgramSQL
BEGIN
  FOR 
   SELECT
    BOUND_MODULE
   FROM
    QSYS2.BOUND_MODULE_INFO
   WHERE 
    PROGRAM_LIBRARY      = UPPER('$1') AND
    PROGRAM_NAME         = UPPER('$2') AND
    BOUND_MODULE_LIBRARY = UPPER('$3') AND
    BOUND_MODULE         = UPPER('$4')
   DO
    CALL QSYS2.IFS_WRITE(
      PATH_NAME  => '$wSrvPgmDtaFile', 
      LINE       => 'FOUND',
      FILE_CCSID => 1208
    ); END FOR; END;
EOS_sp_checkModuleInServiceProgramSQL
#
  local err=$(callSqlScript "$wSrvPgmSqlFile")
#
  if [ -s "$wSrvPgmDtaFile" ]; then
    echo ""
    runLog "Module Found."
  else
    echo "-1"
    runLog "Module NOT Found."
  fi
}
#
#---------------------------------------------------------------------------------------
#
# $1 - SrvPrg Library
# $2 - SrvPrg Name
# $3 - Module Library
# $4 - Module Name
#
function sp_updateModuleInServiceProgram () {
  log_startFunc "sp_updateModuleInServiceProgram"
  local cmd="UPDSRVPGM SRVPGM($1/$2) MODULE($3/$4) RPLLIB(*MODULE)"
  
  cat > $wSrvPgmSqlFile <<EOS_sp_updateModuleInServiceProgramSQL
CALL qsys2.qcmdexc('$cmd');
EOS_sp_updateModuleInServiceProgramSQL
#
  local err=$(callSqlScript "$wSrvPgmSqlFile")
#

}
