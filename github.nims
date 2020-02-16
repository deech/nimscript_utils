import options,os
import "downloader.nims"
import "extract.nims"

const githubUrl = "https://github.com"

proc downloadGithubCommit*(user: string, project: string, commit: string, outdir: string, proxy : Option[Proxy] = Proxy.none): string =
  let
    zipUrl = githubUrl & "/archive" & commit & ".zip"
    zipDir = project & "-" & commit & ".zip"
  download Config(
    url: zipUrl,
    proxy: proxy,
    outfile: os.getTempDir() / zipDir,
    overwrite: false
  )
  extractZip(os.getTempDir() / zipDir, outdir)
  return outdir / zipDir

