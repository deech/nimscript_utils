import os

proc pushEnv*(env,x:string) =
  if getEnv(env) == "":
    putEnv(env, x)
  else:
    putEnv(env, x & PathSep & getEnv(env))
