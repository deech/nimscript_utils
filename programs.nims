import sequtils
proc missingPrograms*(needed: seq[string]):seq[string] =
  needed.filterIt(system.findExe(it) == "")
