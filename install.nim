import os, strformat
# 'version' must be not be a version range, eg. "> 1.0" will not work.
# 'nimbleDir' must be absolute, eg. "~/.nimble" will not work
proc installOnlyLibrary(name: string, version: string, nimbleDir: string) =
  let pkgs = nimbleDir / "pkgs"
  if not system.dirExists(pkgs):
    raise newException(Defect, fmt"The Nimble packages directory {pkgs} does not exist")
  if not system.dirExists(nimbleDir / "pkgs" / fmt"{name}-{version}"):
    let tempNimbleDir = getTempDir() / "nimbleDir"
    if not system.dirExists tempNimbleDir: mkDir tempNimbleDir
    exec fmt"""nimble install -y --nimbleDir:{tempNimbleDir} {name}@"{version}" """
    mvDir(tempNimbleDir / "pkgs" / fmt"{name}-{version}", nimbleDir / "pkgs" / fmt"{name}-{version}")
