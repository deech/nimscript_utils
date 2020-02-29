import parsecfg, os, tables

let confFile = getConfigDir() / "nimble" / "nimble.ini"
var nimbleDir = ""
if (os.existsFile confFile):
  for table in loadConfig(confFile).values:
    for (k,v) in table.pairs:
      if k == "nimbleDir": nimbleDir = v
echo nimbleDir
