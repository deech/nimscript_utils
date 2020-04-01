import system, strformat
when defined(windows):
  import options, os
  import downloader

proc extractZip*(file,outputDir: string) =
  when not defined(windows):
    if system.findExe("unzip") == "":
      raise newException(Defect, "'unzip' is required but could not be found.")
    echo fmt"Extracting to {file}"
  let cmd =
    when not defined(windows):
      fmt "unzip -o {file} -d {outputDir}"
    else:
      # stolen from nimterop source
      "powershell -nologo -noprofile -command \"& { Add-Type -A " &
      "'System.IO.Compression.FileSystem'; " &
      "[IO.Compression.ZipFile]::ExtractToDirectory('" & file & "', '" & outputDir & "'); }\""
  let (output,err) = gorgeEx cmd
  if err != 0:
    raise newException(OSError, output)

const link7z* = "https://www.7-zip.org/a/7z1900-x64.exe"
const exe7z* = "7zG.exe" # provided by Nim on Windows

proc extractTarxz*(file,outputDir: string): string =
  when defined(windows):
    # unpack a thing.tar.xz to thing.tar
    discard staticExec(fmt"{exe7z} x {file} -aoa -o{outputDir}")
    # unpack thing.tar to thing because that's how 7z rolls
    staticExec(fmt("{exe7z} x { outputDir / file.splitFile.name } -aoa -o{outputDir}"))
  when defined(macosx): staticExec(fmt"tar --extract --file {file} --directory {outputDir}")
  else: staticExec(fmt"tar --extract --file {file} --directory {outputDir} --overwrite")
