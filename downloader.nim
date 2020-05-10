import options, uri, os, system, strutils, system/nimscript, tables, sequtils

type
  ProxyAuth* = enum Basic, Digest, NoAuth
  Proxy* = object
    server: string
    case kind: ProxyAuth
    of Basic .. Digest: user,password:string
    of NoAuth: discard
  Config* = object
    url*: string
    proxy*: Option[Proxy]
    outfile*: string
    overwrite*: bool

template err(msg:untyped) =
  raise newException(Defect, msg)

proc getProxyAuth*(cli: Table[string,string]):Option[Proxy] =
  template hasParams(ps: untyped): untyped =
    allIt(mapIt(ps, cli.hasKey(it)), it)
  if hasParams @["proxyUrl", "proxyUser", "proxyPass", "proxyAuth"]:
    case cli["proxyAuth"].toLower
    of "basic": some(Proxy(server: cli["proxyUrl"],
                           kind: Basic,
                           user: cli["proxyUser"],
                           password: cli["proxyPass"]))
    of "digest": some(Proxy(server: cli["proxyUrl"],
                            kind: Digest,
                            user: cli["proxyUser"],
                            password: cli["proxyPass"]))
    else: err(" Unknown proxyAuth : " & cli["proxyAuth" ] & ", only 'basic' and 'digest' are recognized.")
  elif hasParams @["proxyUrl", "proxyUser", "proxyPass"]:
    some(
      Proxy(
        server: cli["proxyUrl"],
        kind: Basic,
        user: cli["proxyUser"],
        password: cli["proxyPassword"]
      )
    )
  elif hasParams @["proxyUrl", "proxyAuth", "proxyUser"]:
    err("Need a password (proxyPassword) for the proxy server.")
  elif hasParams @["proxyUrl", "proxyAuth", "proxyPassword"]:
    err("Need a user (proxyUser) for the proxy server ")
  elif hasParams @["proxyUrl", "proxyAuth"]:
    err(" A proxy server is specified with auth: " & cli["proxyAuth"] & " but no user or password given.")
  elif hasParams @["proxyUrl"]:
    some(
      Proxy(
        server: cli["proxyUrl"],
        kind: NoAuth
      )
    )
  else:
    Proxy.none

proc download*(c: Config) =
  when not defined(windows):
    if system.findExe("curl") == "":
      err("'curl' is required.")
  let (dir,f) = os.splitPath c.outFile
  if (not system.existsDir dir):
    err("The output directory: " & dir & " does not exist.")
  if f == "":
    err("No output file name specified.")
  if (system.existsFile(c.outfile) and not c.overwrite):
    err("The output file exists and cannot be overwritten.")
  let userAgent = "downloader/" & nimscript.version & "(" & nimscript.buildOS & ";" & nimscript.buildCPU & ")"
  let downloadScript =
    when defined(windows):
      nimscript.thisDir() & "download.ps1"
    else:
      nimscript.thisDir() & "download.sh"
  let (url,queryParams) =
    block:
      let uri = c.url.parseUri
      var noQps = uri
      noQps.query = ""
      ($noQps,uri.query)
  when defined(windows):
    var cli = @[ "powershell.exe"
                 , "-ExecutionPolicy", "bypass"
                 , "-NonInteractive"
                 , "-NoProfile"
                 , "-File", downloadScript
                 , "-url" , $url
                 , "-outputPath" , c.outfile
                 , "-userAgent", userAgent]
    if queryParams != "": cli.add @["-queryParams", queryParams]
    c.proxy.map(
      proc (p:Proxy) =
        cli.add @["--proxy", $p.server.parseUri]
        case p.kind
        of NoAuth: discard
        else: cli.add @["-user", p.user, "-pass", p.password, "-auth", if p.kind == Basic: "basic" else: "digest" ]
    )
  else:
    var cli = @["sh", downloadScript, $url, queryParams.escape, c.outfile, userAgent.escape]
    c.proxy.map(
      proc (p:Proxy) =
        cli.add $p.server.parseUri
        case p.kind
        of NoAuth: discard
        else: cli.add @[p.user & ":" & p.password, if p.kind == Basic: "basic" else: "digest"]
    )
  let (output, exitCode) = system.gorgeEx strUtils.join(cli, " ")
  if exitCode != 0:
    echo output
    err("Unable to download from " & c.url & " to " & c.outfile)
  else:
    when defined(windows):
      if not output.startsWith("200"): err(output)
    else:
      try:
        if output.parseInt != 200:
          err("HTTP error code: " & output)
      except ValueError:
        err("Expecting an HTTP return code but got: " & output)
