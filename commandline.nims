import system, strutils, tables
const cli* =
  block:
    var res : seq[string] = @[]
    for i in 0 .. system.paramCount():
      res.add(system.paramStr(i))
    res

proc getValues*(cli: seq[string]): tuple[switches: seq[string], keyValues: Table[string,string]]  =
  var switches : seq[string]
  var keyValues: seq[(string,string)]
  for arg in cli:
    if (arg.startsWith("--")):
      var res = arg.split(":", maxsplit=1)
      if res.len == 1:
        res = arg.split("=", maxSplit=1)
        if res.len == 1:
          switches.add res[0].strip
        else:
          keyValues.add (res[0].strip,res[1].strip)
    else:
      switches.add arg.strip
  result = (switches: switches, keyValues: keyValues.toTable)
