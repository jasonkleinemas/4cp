#
#---------------------------------------------------------------------------------------
#
function setCompileCommand {
  case "${wObjectType}" in
    crtsrvpgm)
      od_rtnObjectList "$oObject"
      oObjectList=$s_od_rol
      setSystemCommand "
CRTSRVPGM
  MODULE($oObjectList)
  SRVPGM($oLibrary/$oObject)
  TEXT('$oText')
  EXPORT(*ALL)
  OPTION(*EVENTF)";
      ;;
    crtpgm)
      rtnObjectList "$oObject"
      oObjectList=$s_od_rol
      setSystemCommand "
CRTPGM
  BNDSRVPGM($oObjectList)
  MODULE($oLibrary/$oObject)
  PGM($oLibrary/$oObject)
  TEXT('$oText')
  OPTION(*EVENTF)";
      ;;
    rpgle)
      setSystemCommand "
CRTBNDRPG 
  SRCSTMF('$wFileFullPath') 
  PGM($oLibrary/$oObject) 
  TEXT('$oText')
  OPTION(*EVENTF)";
      ;;
    rpgle_mod)
      setSystemCommand "
CRTRPGMOD 
  SRCSTMF('$wFileFullPath') 
  MODULE($oLibrary/$oObject) 
  TEXT('$oText')
  OPTION(*EVENTF)";
      ;;
    sqlrpgle)
      setSystemCommand "
CRTSQLRPGI
  SRCSTMF('$wFileFullPath')
  OBJ($oLibrary/$oObject)
  TEXT('$oText')
  RPGPPOPT(*LVL2)
  OPTION(*EVENTF)";
      ;;
    clle)
      setSystemCommand "
CRTBNDCL
  SRCSTMF('$wFileFullPath')
  PGM($oLibrary/$oObject)
  OPTION(*EVENTF)";
      ;;
    cmd)
      setSystemCommand "
CRTCMD
  SRCSTMF('$wFileFullPath')
  CMD($oLibrary/$oObject)
  PGM($oObject)
  OPTION(*EVENTF)";
      ;;
    crtbnddir)
      setSystemCommand "
CRTBNDDIR
  BNDDIR($oLibrary/$oObject)
  TEXT('$oText')";
      ;;
    *)
      setUpOtherfileCommands
      ;;
  esac

}
#
#---------------------------------------------------------------------------------------
#
function setUpOtherfileCommands {
  copySourceFile
  checkObject $oLibrary $oObject "FILE"
  if [ -z $ind_co ]; then
    suofc_replace="*NO"
  else
    suofc_replace="*YES"
  fi

  case "${wObjectType}" in
    dspf)
      setSystemCommand "CRTDSPF SRCFILE($oLibrary/$oPfSrcFile) SRCMBR($oObject) FILE($oLibrary/$oObject) REPLACE($suofc_replace)";
      ;;
    lf)
      setSystemCommand "CRTLF SRCFILE($oLibrary/$oPfSrcFile) SRCMBR($oObject) FILE($oLibrary/$oObject) ";#REPLACE($suofc_replace)";
      ;;
    pf)
      setSystemCommand "CRTPF SRCFILE($oLibrary/$oPfSrcFile) SRCMBR($oObject) FILE($oLibrary/$oObject) ";#REPLACE($suofc_replace)";
      ;;
    pnlgrp)
      setSystemCommand "CRTPNLGRP SRCFILE($oLibrary/$oPfSrcFile) SRCMBR($oObject) PNLGRP($oLibrary/$oObject) REPLACE($suofc_replace)";
      ;;
    prtf)
      setSystemCommand "CRTPRTF SRCFILE($oLibrary/$oPfSrcFile) SRCMBR($oObject) FILE($oLibrary/$oObject) REPLACE($suofc_replace)";
      ;;
    xxxxxx)
      x=""
      ;;
   *)
    echo "Unknown object to compile: $wObjectType"
    exit
    ;;
  esac
}
#
#---------------------------------------------------------------------------------------
#
function copySourceFile () {
  setSystemCommand "CHKOBJ OBJ($oLibrary/$oPfSrcFile) OBJTYPE(*FILE)"
  runSystemCommand
  if [ -z $wLastCmdError ]; then
  # Source file found
    setSystemCommand "CHKOBJ OBJ($oLibrary/$oPfSrcFile) OBJTYPE(*FILE) MBR($oObject)"
    runSystemCommand
  if [ -z $wLastCmdError ]; then
    # Source member found
      oMbrOptions="*REPLACE"
    else
      oMbrOptions="*NONE"
    fi
  else
  # Source file not found
    setSystemCommand "CRTSRCPF FILE($oLibrary/$oPfSrcFile) RCDLEN(200) TEXT('$oText')"
    runSystemCommand
    oMbrOptions="*NONE"
  fi
  setSystemCommand "CPYFRMSTMF FROMSTMF('$wFileFullPath') TOMBR('/QSYS.LIB/$oLibrary.LIB/$oPfSrcFile.FILE/$oObject.MBR') MBROPT($oMbrOptions)"
  runSystemCommand
  setSystemCommand "CHGPFM FILE($oLibrary/$oPfSrcFile) MBR($oObject) SRCTYPE($oSrcMbrType) TEXT('$oText')"
  runSystemCommand
}
#
#---------------------------------------------------------------------------------------
#
function afterSuccesfullCompile () {
  case "${wObjectType}" in
    rpgle_mod)
      ;&
    sqlrpgle_mod)
      sp_putModuleInServiceProgram "$oLibrary" "$oObject" 
      ;;
    *)
      local doNothing=""
      ;;
  esac
}
#
#---------------------------------------------------------------------------------------
#
function writeCompileErrorFileSQL () {
#
# $1 - Object Library   $oLibrary
# $2 - Object Name      $oObject
#
# Zero out output file
#
> $wTempDirExpanded/$wCompileErrFileName
#
# Start of block

#CALL QSYS2.IFS_WRITE(
#  PATH_NAME   => '$wTempDirExpanded/$wCompileErrFileName', 
#  LINE        => '',
#  OVERWRITE   => 'REPLACE',
#  END_OF_lINE => 'NONE',
#  FILE_CCSID => 1208
#);
#
cat > $wTempDirExpanded/$wCompileSqlFileName <<EOS_writeCompileErrorFileSQL

CREATE ALIAS QTEMP.${2} FOR ${1}.EVFEVENT(${2});

BEGIN
  FOR 
   SELECT 
    EVFEVENT,
    SUBSTR(EVFEVENT , 66 ) AS EVENT2 
   FROM
    QTEMP.${2} 
   WHERE
    SUBSTR(EVFEVENT , 1  , 5 ) =  'ERROR' AND 
    SUBSTR(EVFEVENT , 49 , 7 ) != 'RNF7031' 
   DO
    CALL QSYS2.IFS_WRITE(
      PATH_NAME  => '$wTempDirExpanded/$wCompileErrFileName', 
      LINE       => TRIM(EVENT2),
      FILE_CCSID => 1208
    ); END FOR; END;

DROP ALIAS QTEMP.${2};
EOS_writeCompileErrorFileSQL
#
# End of block
#
  local err=$(callSqlScript "$wTempDirExpanded/$wCompileSqlFileName")
}
#
#---------------------------------------------------------------------------------------
#
function checkForSuccesfullCompileByObjType () {
    echo $clr_wh
    case "${wObjectType}" in
      rpgle_mod)
        ;&
      sqlrpgle_mod)
        ;&
      rpgle)
        ;&
      sqlrpgle)
        ind_cfscbot=$(eval tail -n3 $oStdOutFile |grep " 00 highest")
        ;;
      dspf)      
        ind_cfscbot=$(eval tail -n3 $oStdOutFile |grep "CPC7301      00")
        ;;
      pf)
        x=""
        ;;
    esac
    echo $clr_nc
}