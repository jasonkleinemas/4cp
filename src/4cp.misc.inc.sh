#
#---------------------------------------------------------------------------------------
#
function runSystemCommand {
  runLog "$oSystemcommand"
  eval $oSystemcommand
  wLastCmdError=$(eval cat $oStdErrFile)
  if [ -z "$wDebug" ] ; then
    wDebug=""
  else
    echo $? $oSystemcommand
    eval cat $oStdErrFile
  fi
}
#
#---------------------------------------------------------------------------------------
#
# option
# i - Run in current job 
# k - Keep Spool Files
# K - Produce job log
# s - Do not process spool file. Do not send to stdout.
#
function setSystemCommand () {
  
  oCompileCommand=$1
  local wt=$(echo "${oCompileCommand//[$'\t\r\n']}")
  oSystemcommand="system -e -i \"${wt}\" >$oStdOutFile 2>$oStdErrFile ;"  
}
#
#---------------------------------------------------------------------------------------
#
function setUploadCommand {
 x=""
}
#
#---------------------------------------------------------------------------------------
#
# $1 - Script File on IFS max 50 chars
#
function callSqlScript () {
  runLog "$(cat $1)"
  local err=$(qsh -c "db2 -t -f $1")
  if [ $err == "DB20000I  THE SQL COMMAND COMPLETED SUCCESSFULLY." ]; then
    echo ""
  else
    writeToLastRunLog "callSqlScript:$clr_rd$err$clr_nc"
    echo "-1"
  fi
}
#
#---------------------------------------------------------------------------------------
#
# $1 - Library
# $2 - Object
# $3 - Object Type No * as in FILE not *FILE
#
# $ind_co - Set to blank if object found.
#
function checkObject () {
  log_startFunc "checkObject"
#
# Zero out output file
#
  > $wChkObjDtaFile
#
  cat > $wChkObjSqlFile <<EOS_wChkObjSqlFileNameSQL
BEGIN
  FOR 
   SELECT
    OBJNAME, 
    OBJTYPE 
   FROM
    TABLE (QSYS2.OBJECT_STATISTICS(UPPER('$1'),UPPER('$3'),'*ALLSIMPLE')) 
   WHERE 
    OBJNAME = UPPER('$2')
   DO
    CALL QSYS2.IFS_WRITE(
      PATH_NAME  => '$wChkObjDtaFile', 
      LINE       => 'FOUND',
      FILE_CCSID => 1208
    ); END FOR; END;
EOS_wChkObjSqlFileNameSQL
#
  local err=$(callSqlScript "$wChkObjSqlFile")
#
  if [ -s "$wChkObjDtaFile" ]; then
    ind_co=""
    runLog "Object Found."
  else
    ind_co="-1"
    runLog "Object NOT Found."
  fi
}
#
#---------------------------------------------------------------------------------------
#
# $1 - Text to log
#
function runLog () {
  if [ -n "$wLogEverything" ]; then
    writeToLastRunLog "$1"
  fi
}
#
#---------------------------------------------------------------------------------------
#
# $1 - Text to log
#
function writeToLastRunLog () {
  local ww=`date +"%D %T"`
  echo "$clr_wh$ww$clr_gr:$clr_nc$1" >>$wLastRunLogFile
}
#
#---------------------------------------------------------------------------------------
#
# $1 - Text to log
#
function log_startFunc () {
  writeToLastRunLog "$clr_gr***$clr_nc$clr_yl Start$clr_nc $clr_gr***$clr_nc $clr_yl$1$clr_nc $clr_gr***$clr_nc"
}