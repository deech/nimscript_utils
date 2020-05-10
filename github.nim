import options,os
import downloader
import extract

const githubUrl = "https://github.com"

proc downloadGithubCommit*(user: string, project: string, commit: string, outdir: string, proxy : Option[Proxy] = Proxy.none, overwrite = false): string =
  let
    zipUrl = githubUrl & "/" & user & "/" & project & "/" & "/archive/" & commit & ".zip"
    zipDir = project & "-" & commit
    zipFile = zipDir & ".zip"
  if (not system.existsDir(outDir / zipDir)):
    if (not system.existsFile(os.getTempDir() / zipFile)) or overwrite:
       download Config(
         url: zipUrl,
         proxy: proxy,
         outfile: os.getTempDir() / zipFile,
         overwrite: overwrite
       )
    extractZip(os.getTempDir() / zipDir, outdir)
  result = outdir / zipDir
