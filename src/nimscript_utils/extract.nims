import system, strformat

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
      let powerShellCmd =
        "powershell -nologo -noprofile -command \"& { Add-Type -A " &
        "'System.IO.Compression.FileSystem'; " &
        "[IO.Compression.ZipFile]::ExtractToDirectory('{file}', '{outputDir}'); }\""
      fmt powershellCmd
  let (output,err) = gorgeEx cmd
  if err != 0:
    raise newException(OSError, output)

const link7z* = "https://www.7-zip.org/a/7z1900-x64.exe"
const exe7z* = "7za.exe"

when defined(windows):
  proc get7z*(dir: string, proxy: Option[Proxy]) =
    download(Config(url: link7z, proxy: proxy, outdir: dir, outfile: dir / exe7z, overwrite: true))

proc extractTarxz*(file,outputDir: string): string =
  when defined(windows): staticExec(fmt"{7zexe} x {file} -aoa -o{outputDir}")
  else: staticExec(fmt"tar --extract --file {file} --directory {outputDir} --overwrite")
