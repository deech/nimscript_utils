import system, sequtils, strutils, tables, strformat
const cli* =
  block:
    var res : seq[string] = @[]
    for i in 0 .. system.paramCount():
      res.add(system.paramStr(i))
    res

proc getValues*(cli: seq[string], keys: seq[string]): Table[string,string] =
  cli.mapIt(
    block:
      let arg = it
      if (keys.anyIt(arg.startsWith(fmt"--{it}"))):
        let split = arg.split(":", maxsplit=1)
        var key : string = split[0]
        key.removePrefix("--")
        @[(key,split[1])]
      else:
        @[]
  ).concat.toTable
