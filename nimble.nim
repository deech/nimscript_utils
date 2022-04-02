import system,os,tables,strformat,parsecfg
proc getNimbleDir*():string =
  if (let x = getValues(cli).keyValues.getOrDefault("nimbleDir",""); x != ""): result = x
  elif (let x = getEnv("NIMBLE_DIR"); x != ""): result = x
  else:
    let confFile = getConfigDir() / "nimble" / "nimble.ini"
    var nimbleDir : string
    if (system.existsFile confFile):
       for table in loadConfig(newStringStream(readFile confFile)).values:
         for (k,v) in table.pairs:
           if k == "nimbleDir": nimbleDir = v
    if nimbleDir != "" : result = nimbleDir
    else:
      let x = getHomeDir() / ".nimble"
      if system.dirExists x: result = x
