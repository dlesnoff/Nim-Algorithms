## Check Anagram
## =============
## wiki: https://en.wikipedia.org/wiki/Anagram
##
## Two words are anagrams if:
## - They are made up of the same letters.
## - The letters are arranged differently.
## - They are not the same word (a word is not an anagram of itself).
## - The case of word's characters is ignored.
##
## A word is any string of characters `{'A'..'Z', 'a'..'z'}`. Other characters,
## including whitespace and puctuation, are considered invalid and raise a
## `ValueError` exception.
##
## Note: Generate full doc with `nim doc --docinternal check_anagram.nim`

runnableExamples:
  doAssert "coder".isAnagram("credo")

  doAssert not "Nim".isAnagram("Nim")

  doAssert not "parrot".isAnagram("rapport")

  let raisedException = try:
      discard "Pearl Jam".isAnagram("Maple Jar")
      false
    except ValueError:
      true
  doassert raisedException

## Tests
## -----
## This module includes test suites for each public function, which run when
## compiled as a program.
##
## TODO
## ----
##
## - Unicode version of the algorithm.

type
  Map = array[range['a'..'z'], Natural] ## An associative array with a direct
                                        ## mapping from Char to a counter slot

const
  UpperAlpha = {'A'..'Z'}
  LowerAlpha = {'a'..'z'}

func toLowerUnchecked(c: char): char =
  ## Lowers the case of an ASCII uppercase letter ('A'..'Z').
  ## No checks performed, the caller must ensure the input is a valid character.
  ##
  ## See also:
  ## * strutils.toLowerAscii
  assert c in UpperAlpha
  char(uint8(c) xor 0b0010_0000'u8)

template normalizeChar(c: char) =
  ## Checks if the character is a letter and lowers its case.
  ##
  ## Raises a ValueError on other characters.
  if c in LowerAlpha: c
  elif c in UpperAlpha: toLowerUnchecked(c)
  else: raise newException(ValueError, "Character '" & c & "' is not a letter!")

func isAnagram*(a, b: openArray[char]): bool {.raises: ValueError.} =
  ## Checks if two words are anagrams of one another.
  ##
  ## Raises a ValueError on any non-letter character.
  if a.len != b.len: return false
  var seenDifferent = false
  var mapA, mapB: Map
  for chIdx in 0..<a.len:
    let (chA, chB) = (normalizeChar(a[chIdx]), normalizeChar(b[chIdx]))
    # Identical characters xor to 0, must meet at least one 1 (difference)
    seenDifferent = bool(ord(seenDifferent) or (ord(chA) xor ord(chB)))
    mapA[chA].inc()
    mapB[chB].inc()
  # words are not identical and letter counters match
  seenDifferent and (mapA == mapB)

func isAnagram(a, bNormalized: openArray[char]; bMap: Map): bool {.raises: ValueError.} =
  ## Checks if two words are anagrams of one another.
  ## Leverages a prepared (lowercased) word `bNormalized` and its precalculated
  ## map `bMap` for one-to-many comparisons.
  ##
  ## Raises a ValueError on any non-letter character.
  if a.len != bNormalized.len: return false
  var seenDifferent = false
  var aMap: Map
  for chIdx in 0..<a.len:
    let (chA, chB) = (normalizeChar(a[chIdx]), bNormalized[chIdx])
    # Identical characters xor to 0, must meet at least one 1 (difference)
    seenDifferent = bool(ord(seenDifferent) or (ord(chA) xor ord(chB)))
    aMap[chA].inc()
  # words are not identical and letter counters match
  seenDifferent and (aMap == bMap)

func filterAnagrams*(word: string; candidates: openArray[string]): seq[string] {.raises: ValueError.} =
  ## Checks if any of the candidates is an anagram of a `word` and returns them.
  ##
  ## Raises a ValueError on any non-letter character.
  var wordMap: Map
  var wordNormalized = newString(word.len)
  for chIdx, c in word.pairs():
    let c = normalizeChar(c)
    wordNormalized[chIdx] = c
    wordMap[c].inc()
  for candidate in candidates:
    if candidate.isAnagram(wordNormalized, wordMap): result.add(candidate)

when isMainModule:
  import std/unittest
  from std/sequtils import allIt, filterIt, mapIt

  suite "Check `isAnagram`":
    test "Only alphabetical characters are allowed":
      expect(ValueError): discard "n00b".isAnagram("8ooN")

    test "Detects an anagram":
      check "aceofbase".isAnagram("boafaeces")

    test "A word is not an anagram of itself":
      check not "nim".isAnagram("nim")

    test "A word is not an anagram of itself case-insensitively":
      check not "fnord".isAnagram("fNoRd")

    test "Character count matters":
      check not "tapper".isAnagram("patter")

    test "All matches":
      const word = "MilesDavis"
      const anagrams = ["VileSadism", "DevilsAmis", "SlimeDivas", "MassiveLid"]
      check anagrams.allIt(word.isAnagram(it))

    test "No matches":
      const word = "alice"
      const candidates = ["bob", "carol", "dave", "eve"]
      check candidates.allIt(not word.isAnagram(it))

    test "Detects anagrams case-insensitively":
      const word = "solemn"
      const candidates = ["LEMONS", "parrot", "MeLoNs"]
      check candidates.mapIt(word.isAnagram(it)) == [true, false, true]

    test "Does not detect anagram subsets":
      const word = "good"
      const candidates = @["dog", "goody"]
      check candidates.filterIt(word.isAnagram(it)).len == 0

  suite "Check `filterAnagrams`":
    test "Only alphabetical characters are allowed":
      expect(ValueError): discard "n00b".filterAnagrams(["8ooN", "1337"])

    test "A word is not an anagram of itself, case-insensitively":
      const candidates = ["fnord", "FnOrD"]
      check "fnord".filterAnagrams(candidates).len == 0

    test "Detects anagrams":
      const word = "MilesDavis"
      const anagrams = ["VileSadism", "DevilsAmis", "SlimeDivas", "MassiveLid"]
      check word.filterAnagrams(anagrams) == anagrams

    test "No matches":
      const word = "alice"
      const candidates = ["bob", "carol", "dave", "eve"]
      check word.filterAnagrams(candidates).len == 0

    test "Detects anagrams case-insensitively":
      const word = "solemn"
      const candidates = ["LEMONS", "parrot", "MeLoNs"]
      check word.filterAnagrams(candidates) == [candidates[0], candidates[2]]
