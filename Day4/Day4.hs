{- stack
  script
  --resolver lts-10.3
-}
import System.IO ( IOMode(ReadMode), withFile, hGetContents)
import Data.List (sortBy, isInfixOf)
import Data.List.Split (splitOn)
import Data.Char (chr)
import Data.Map (fromListWith, toList)

-- http://stackoverflow.com/questions/7108559/how-to-find-the-frequency-of-characters-in-a-string-in-haskell/7108719#7108719
-- added in explicit typing. not needed but i find it helping...
makeCountMap ::  [Char] -> [(Char, Int)]
makeCountMap inputString = 
 toList $ fromListWith (+) [(c, 1) | c <- inputString]

splitLast :: [Char] -> [Char] -> [[Char]]
splitLast c s = do
 let z = splitOn c s
 let j = length z -1
 if j > 0
  then [ concat(take j z), z !! (j)]
  else [s]

-- http://stackoverflow.com/questions/30242668/remove-characters-from-string-in-haskell
removePunc xs = [ x | x <- xs, not (x `elem` ",.?!-:;\"\'[]") ]

data MyContainer = Foo [(Char, Int)] Int [Char] [Char] deriving (Show)
data MyContainer2 = DecodedRoom [Char] Int deriving (Show)

getComponents :: [Char] -> MyContainer
getComponents line = do
 let h = splitOn "[" line
 let g = splitLast "-" (h !! 0)
 Foo (makeCountMap (removePunc (g!!0))) (read (g!!1) :: Int) (init (h !! 1)) (h !! 0)



verifyChecksum :: MyContainer -> Bool
verifyChecksum (Foo inMap _ inCheck _) = do
 let testee = takeFive inMap
 if testee == inCheck
  then True
  else False

takeFive :: [(Char, Int)] -> [Char]
takeFive x = take 5 [ fst tu | tu <- sortBy mySort x]

mySort (c1,i1) (c2,i2)
 | i1 < i2 = GT
 | i1 > i2 = LT
 | c1 > c2 = GT
 | c1 < c2 = LT

getInt (Foo _ i _ _) = i
getNameFromRoom (DecodedRoom c _) = c

roomSort (DecodedRoom n1 _ ) (DecodedRoom n2 _ ) 
 | n1 > n2 = GT
 | n2 > n1 = LT


dechiper :: MyContainer -> MyContainer2
dechiper (Foo _ sectorId _ crypto) = do
 let z = map (\w -> shiftAlpha w sectorId) crypto
 DecodedRoom z sectorId

alphaMin = fromEnum 'a'
alphaMax = fromEnum 'z'
alphaRange = alphaMax - alphaMin + 1
shiftAlpha :: Char -> Int -> Char
shiftAlpha letterIn shift =
 if letterIn == '-'
  then ' ' -- swap - to space
  else
   let charAsInt = fromEnum letterIn -- what ascii index?
       relative = charAsInt - alphaMin  -- how much ahead of "a" is it?
       dechiperedCharIntRelative = (relative + shift) `mod` alphaRange
       w = alphaMin + dechiperedCharIntRelative
   in chr w

task4a handle = do
 contents <- hGetContents handle
 let l = lines contents
 let c = map getComponents l
 let c2 = filter verifyChecksum c
 let j = map getInt c2 
 print $ sum j

task4b handle = do
 contents <- hGetContents handle
 let l = lines contents
 let c = map getComponents l
 let trueRooms = filter verifyChecksum c
 let decrypted = map dechiper trueRooms
 let interesting = filter (\w -> "north" `isInfixOf` (getNameFromRoom w)) decrypted
 let sorted = sortBy roomSort interesting
 mapM_ print sorted

main = do
 putStrLn "Answer to A:"
 withFile "input.txt" ReadMode task4a
 putStrLn "Answer to B:"
 withFile "input.txt" ReadMode task4b