+++
draft = true
tags = ["FP", "Theory"]
title = "Monad Transformers"
+++

```haskell
{- The Identity functor (which is also a monad) -}
newtype Identity a = MkIdentity a

runIdentity :: Identity a -> a
runIdentity (MkIdentity x) = x

instance Functor Identity where
  fmap f (MkIdentity x) = MkIdentity (f x)
instance Applicative Identity where
  pure = MkIdentity
  (<*>) (MkIdentity f) (MkIdentity x) = MkIdentity (f x)
instance Monad Identity where
  (>>=) (MkIdentity x) f = f x

{------------------------------------------------------------------}
  
{- The State monad transformer -}
newtype StateT s m a = MkStateT (s -> m (s, a))

runStateT :: StateT s m a -> s -> m (s, a)
runStateT (MkStateT m) = m

instance Monad m => Functor (StateT s m) where
  fmap f x = do { x' <- x; pure (f x') }
instance Monad m => Applicative (StateT s m) where
  pure x = MkStateT (\s -> pure (s, x))
  (<*>) f x = do { f' <- f; x' <- x; pure (f' x') }
instance Monad m => Monad (StateT s m) where
  {- This do-notation is for m, not StateT m s. -}
  (>>=) (MkStateT x) f = MkStateT (\s -> do
    (s', x') <- x s
    runStateT (f x') s')

{------------------------------------------------------------------}

{- The Result monad transformer. -}
newtype ResultT e m a = MkResultT (m (Either e a))

runResultT :: ResultT e m a -> (m (Either e a))
runResultT (MkResultT m) = m

{- Note that pure and (>>=) are the only ones that aren't "mechanical";
 - this is true of monads in general. -}
instance Monad m => Functor (ResultT e m) where
  fmap f x = do { x' <- x; pure (f x') }
instance Monad m => Applicative (ResultT e m) where
  pure x = MkResultT (pure (Right x))
  (<*>) f x = do { f' <- f; x' <- x; pure (f' x') }
instance Monad m => Monad (ResultT e m) where
  {- This do-notation is again for m, not ResultT m e. -}
  (>>=) (MkResultT x) f = MkResultT (do
    x' <- x
    case x' of
      Left err -> pure (Left err)
      Right x  -> runResultT (f x))

{------------------------------------------------------------------}

{- The State monad is then just an alias -}
type State s = StateT s Identity

{- As is the Result monad -}
type Result e = ResultT e Identity

{- But I can also make e.g. -}
type MyCoolMonad = StateT [String] (ResultT Error Identity)
{- Note that this means Identity wrapped around Result wrapped around State;
 - needing to read monad transformer types inside out is a significant
 - downside. -}
 
data Error
  = StringNotFound String
  | TooManyStrings String Int
  deriving Show

runMyCoolMonad :: MyCoolMonad a -> [String] -> Either Error ([String], a)
runMyCoolMonad m s = runIdentity (runResultT (runStateT m s))

{------------------------------------------------------------------}

throw :: Monad m => e -> ResultT e m a
throw err = MkResultT (pure (Left err))

get :: Monad m => StateT s m s
get = MkStateT (\s -> pure (s, s))

{------------------------------------------------------------------}

{- The problem with those is that I can't do this: -}
{-
ensureString :: String -> MyCoolMonad ()
ensureString s = do
  ss <- get
  if s `elem` ss then
    return ()
  else
    {- Type error here: throw is not MyCoolMonad, it's ResultT -}
    throw (StringNotFound s)
-}

{------------------------------------------------------------------}

{- The solution is to make lifting into monad transformers a thing: -}
class MonadTrans t where
  {- This is the function I'm having trouble encoding into OftLisp...
   - Because return type inference is hard. -}
  lift :: Monad m => m a -> t m a

instance MonadTrans (ResultT e) where
  lift m = MkResultT (fmap Right m)

instance MonadTrans (StateT s) where
  lift m = MkStateT (\s -> fmap (\x -> (s, x)) m)

{------------------------------------------------------------------}

{- Now we can define get and throw that work from the middle of a
 - transformer stack: -}

get' :: (MonadTrans t, Monad m) => t (StateT s m) s
get' = lift get

throw' :: (MonadTrans t, Monad m) => e -> t (ResultT e m) a
throw' = lift . throw

{------------------------------------------------------------------}

ensureString :: String -> MyCoolMonad ()
ensureString s = do
  ss <- get
  if s `elem` ss then
    return ()
  else
    throw' (StringNotFound s)

{------------------------------------------------------------------}

main :: IO ()
main = do
  let exampleState = ["foo", "bar"]
  case runMyCoolMonad (ensureString "baz") exampleState of
    Left err -> putStr "Error: " >> print err
    Right _ -> putStrLn "All is fine (tho it shouldn't've been)"
```
