+++
title = "Notebook: Stahl (Language)"

[taxonomies]
tags = ["stahl", "stahl-lang"]
+++

main function
=============

with Haskell syntax:

```haskell
-- defined by main module
data State
initState :: State
initState = undefined
main :: [Message] -> IO State ()
main = undefined

entrypoint :: [Message] -> State -> ([Message], Maybe State)
entrypoint = runIO . main

-- Approximately ContT () (WriterT [Message] (StateT s Maybe)) a
data IO s a
  = MkIO ((a -> s -> ([Message], Maybe s)) -> s -> ([Message], Maybe s))
  deriving (Functor, Applicative, Monad)

runIO :: IO State () -> State -> ([Message], Maybe State)
runIO (MkIO k) st = k (\(), st => ([], Just st)) st

send :: Message -> IO s ()
send = undefined

modifyIO :: (s -> (s, a)) -> IO s a
modifyIO = undefined

callCCIO :: ((a -> IO s b) -> IO s a) -> IO s a
callCCIO = undefined

exit :: IO a
exit = undefined
```

**TODO:** state and prove some laws -- notably to ensure callCC works
