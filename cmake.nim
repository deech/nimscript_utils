import os, strutils
proc runCmake*(parent:string,flags: seq[string], buildDir :string = "build", post: seq[string] = @["make install"]) =
  let cmakeBuildDir = parent / buildDir
  if not (system.dirExists cmakeBuildDir):
    mkDir cmakeBuildDir
  withDir cmakeBuildDir:
    exec ("cmake .. " & join(flags, " "))
    for command in post:
      exec command
