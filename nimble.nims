import system,os,tables,strformat
import "commandline.nims"
proc getNimbleDir*():string =
  if (let x = getValues(cli, @["nimbleDir"]).getOrDefault(""); x != ""): result = x
  elif (let x = getEnv("NIMBLE_DIR"); x != ""): result = x
  else:
    # Check nimble.ini, but we need 'parsecfg' to marshal it which doesn't to
    # work in nimscript so we have to compile an executable and call out to it.
    let iniUtility = thisDir() / "nimbleDirFromIni"
    if not system.existsFile iniUtility:
      exec fmt"nim --out:{iniUtility} c {iniUtility}.nim"
    if (let x = gorge iniUtility; x != ""): result = x
    else:
      let x = getHomeDir() / ".nimble"
      if system.existsDir x: result = x
