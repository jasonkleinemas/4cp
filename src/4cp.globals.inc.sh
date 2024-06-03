#
#
#


  optspec="l:f:s:cdeghutx"
  
  clr_nc="$(echo -e "\033[0m")"
  clr_cy="$(echo -e "\033[00;36m")" # Cyan
  clr_gr="$(echo -e "\033[00;32m")" # Green
  clr_yl="$(echo -e "\033[00;33m")" # Yellow
  clr_rd="$(echo -e "\033[00:31m")" # Red
  clr_pp="$(echo -e "\033[01:35m")" # Megenta
  clr_wh="$(echo -e "\033[00:37m")" # White
  
  wCompile=""
  wUpload=""
  wTestOnly=""
  wLastCmdError=""
  
  wDebug=""
  wDebugDisplay=""
  
  wObjectName=""
  wObjectType=""

  wFileFullPath=""

  iFile=""
  iLibrary=""
  
  oLibrary=""
  oObject=""
  oText=""
  oSrcMbr=""
  oSrcMbrType=""
  oMbrOptions=""
  oPfSrcFile=QSRC
  
  oObjectList=""
  
  oCompileCommand=""
  oSystemcommand=""
  
  wLogEverything=""
  
  wTempDir="~/.4cp"
  wTempDirExpanded="$(echo ~/.4cp)" # Use this when not bash command
  
  
  wObjectDescriptionFile="_obj_desc.csv"
  wLastRunLogFile="$wTempDirExpanded/lastRunLog.txt"
  >$wLastRunLogFile

  oStdOutFile="$wTempDir/lastCmdStd.txt"
  oStdErrFile="$wTempDir/lastCmdErr.txt"
  
  wCompileErrFileName="evfevent.err.txt"
  wCompileSqlFileName="evfevent.sql.txt"
 
  wCompileErrFile="$wTempDir/$wCompileErrFileName"
  wCompileSqlFile="$wTempDir/$wCompileSqlFileName"
  
  wSrvPgmDtaFileName="srvpgm.dta.txt"
  wSrvPgmErrFileName="srvpgm.err.txt"
  wSrvPgmSqlFileName="srvpgm.sql.txt"
 
  wSrvPgmDtaFile="$wTempDirExpanded/$wSrvPgmDtaFileName"
  wSrvPgmErrFile="$wTempDirExpanded/$wSrvPgmErrFileName"
  wSrvPgmSqlFile="$wTempDirExpanded/$wSrvPgmSqlFileName"

  wBinddirDtaFileName="bindir.dta.txt"
  wBinddirErrFileName="bindir.err.txt"
  wBinddirSqlFileName="bindir.sql.txt"
 
  wBinddirDtaFile="$wTempDirExpanded/$wBinddirDtaFileName"
  wBinddirErrFile="$wTempDirExpanded/$wBinddirErrFileName"
  wBinddirSqlFile="$wTempDirExpanded/$wBinddirSqlFileName"

  wChkObjDtaFileName="chkobj.dta.txt"
  wChkObjErrFileName="chkobj.err.txt"
  wChkObjSqlFileName="chkobj.sql.txt"
 
  wChkObjDtaFile="$wTempDirExpanded/$wChkObjDtaFileName"
  wChkObjErrFile="$wTempDirExpanded/$wChkObjErrFileName"
  wChkObjSqlFile="$wTempDirExpanded/$wChkObjSqlFileName"  
  
  
#
# Function returns
# 
  ind_co="";         # checkObject()
  ind_cfscbot="";    # checkForSuccesfullCompileByObjType()
#  
  s_od_rol="";       # od_rtnObjectList()
  s_od_rot="";       # od_rtnObjectText()
#
  ind_bd_cfmo="-1"   # bd_checkForModuleObject()
  ind_bd_cfmibd="-1" # bd_checkForModuleInBindDir()

#
#---------------------------------------------------------------------------------------
#
function globalsSet {

  mkdir -p "$wTempDirExpanded"
    
  if [ -z "$wCompile" ] && [ -z "$wUpload" ]; then 
    echo "Compile or upload option missing."
    dspHelpScreen
    exit
  fi


  if [ -z "$iFile" ]; then 
    dspHelpScreen
    echo "$Input file missing."
    exit
  fi

  wObjectName=$(echo $iFile | awk '{n=split($0,a,"/");print a[n]}')
  wObjectType=$(echo $wObjectName | awk -F '.' '{print $NF}')
  wObjectName=$(echo $wObjectName | awk -F '.' '{print $1}')
  
  oSrcMbrType=$wObjectType
  
  wFileFullPath=$(pwd)"/$iFile"
  if [ -f "$wFileFullPath" ]; then
    x=""
  else
    case "${wObjectType}" in
      crtbnddir)
        ;&
      crtsrvpgm)    
        ;&
      crtpgm)
        ;;
      *)
        echo "$clr_rd File Not Found:$wFileFullPath"
        exit
        ;;
    esac
  fi
    
  oObject=$wObjectName
  oLibrary=$iLibrary
  
  oSrcMbr=$wObjectName

  od_rtnObjectText "$wObjectName.$wObjectType"
  oText=$s_od_rot
}