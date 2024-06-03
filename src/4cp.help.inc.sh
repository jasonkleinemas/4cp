#
#
#

#
#---------------------------------------------------------------------------------------
#
function dspDebug {

  if [ -z "$wDebugDisplay" ] ; then
    wDebugDisplay=""
  else
  echo " 
 $clr_lc wCompile       $clr_pp $wCompile          
 $clr_lc wUpload        $clr_pp $wUpload 
 $clr_lc wTestOnly      $clr_pp $wTestOnly

 $clr_lc wObjectName    $clr_pp $wObjectName
 $clr_lc wObjectType    $clr_pp $wObjectType
                    
 $clr_lc wFileFullPath  $clr_pp $wFileFullPath

 $clr_lc iFile          $clr_pp $iFile
 $clr_lc iLibrary       $clr_pp $iLibrary
                      
 $clr_lc oLibrary       $clr_pp $oLibrary
 $clr_lc oObject        $clr_pp $oObject
 $clr_lc oText          $clr_pp $oText
 $clr_lc oSrcMbr        $clr_pp $oSrcMbr
 $clr_lc oSrcMbrType    $clr_pp $oSrcMbrType
 $clr_lc oMbrOptions    $clr_pp $oMbrOptions
 $clr_lc oPfSrcFile     $clr_pp $oPfSrcFile
 
 $clr_lc oObjectList    $clr_pp $oObjectList
  
 $clr_lc CompileCommand $clr_pp$oCompileCommand
 $clr_lc Systemcommand  
 $clr_pp$oSystemcommand $clr_nc"
  fi
}
#
#---------------------------------------------------------------------------------------
#
function dspHelpScreen {

  echo "

  Run this from were the $wObjectDescriptionFile is loacted. Should be base dir of your app.
  
 -h   Display help info
 
 Option c or u                                                       Required
 -c   Compile object
 -u   Data to transfer.

 -d   show debug screen                                              Optinal
 -f   Local file name. First part of file name will be object name.  Required
 -l   Library to put object.                                         Required
 -s   Source file name. Default QSRC                                 Optinal
 -x   Debug messages.                                                Optinal
  "
}
#
#---------------------------------------------------------------------------------------
#
function dspCompileOptions () {
  echo 
  echo "$clr_lc Output frm job:$clr_pp $oStdOutFile $clr_nc"
  echo "                $clr_pp $oStdErrFile $clr_nc"
  echo "                $clr_pp $wCompileErrFile $clr_nc"
  echo "                $clr_pp $wCompileSqlFile $clr_nc"
  echo 
  echo "$clr_lc Command to Run:$clr_gr $oCompileCommand"  
  echo $clr_nc
}
#
#---------------------------------------------------------------------------------------
#
function dspFileGlobals () {
  echo "
$clr_lc wObjectDescriptionFile $clr_pp $wObjectDescriptionFile

$clr_lc wTempDir            $clr_pp $wTempDir
$clr_lc wTempDirExpanded    $clr_pp $wTempDirExpanded

$clr_lc wLastRunLogFile     $clr_pp $wLastRunLogFile

$clr_lc oStdOutFile         $clr_pp $oStdOutFile
$clr_lc oStdErrFile         $clr_pp $oStdErrFile

$clr_lc wCompileErrFile     $clr_pp $wCompileErrFile
$clr_lc wCompileSqlFile     $clr_pp $wCompileSqlFile

$clr_lc wChkObjDtaFile      $clr_pp $wChkObjDtaFile
$clr_lc wChkObjErrFile      $clr_pp $wChkObjErrFile
$clr_lc wChkObjSqlFile      $clr_pp $wChkObjSqlFile

$clr_lc wSrvPgmDtaFile      $clr_pp $wSrvPgmDtaFile
$clr_lc wSrvPgmErrFile      $clr_pp $wSrvPgmErrFile
$clr_lc wSrvPgmSqlFile      $clr_pp $wSrvPgmSqlFile

$clr_lc wBinddirDtaFile     $clr_pp $wBinddirDtaFile
$clr_lc wBinddirErrFile     $clr_pp $wBinddirErrFile
$clr_lc wBinddirSqlFile     $clr_pp $wBinddirSqlFile

$clr_lc wTempDir     $clr_pp $wTempDir
$clr_lc wTempDir     $clr_pp $wTempDir
$clr_lc wTempDir     $clr_pp $wTempDir
$clr_lc wTempDir     $clr_pp $wTempDir
"
}
#
#---------------------------------------------------------------------------------------
#
function commandLineOptionsProcess {
#  echo "optchar:${optchar}"
  case "${optchar}" in
    c)
      wCompile="Y"
      wUpload=""
      ;;
    u)
      wUpload="Y"
      wCompile=""
      ;;
    d)
      wDebugDisplay="Y"
      ;;
    e)
      wLogEverything="Y"
      ;;
    f)
      iFile=$OPTARG
      ;;
    g)
      dspFileGlobals
      ;;
    h)
      dspHelpScreen
      exit
      ;;
    l)
      iLibrary=$OPTARG
      ;;
    s)
      pSrcFile=$OPTARG
      ;;
    t)
      wTestOnly="Y"
      wDebugDisplay="Y"
      ;;
    x)
      wDebugDisplay="Y"
      wDebug="Y"
      ;;
    -)
      local x=""
      ;;
    *)
#      if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then
        echo "Unknown option: '-${OPTARG}'" >&2
#      fi
      ;;
  esac
}
