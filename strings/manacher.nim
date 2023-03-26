# Manacher's algorithm
#[
Determine the longest palindrome in a string in linear time in its length
with Manacher's algorithm
inspired from:
https://github.com/jilljenn/tryalgo/blob/master/tryalgo/manacher.py
https://en.wikipedia.org/wiki/Longest_palindromic_substring
]#
{.push raises: [].}
import std/[strutils, sequtils, sets]

runnableExamples:
  let example1 = "cabbbab"
  doAssert(manacherString(example1) == "abbba")
  doAssert(manacherIndex(example1) == 1 .. 5)
  doAssert(manacherLength(example1) == 5)

func manacherIndex*(s: string): HSlice[int, int] {.raises: [ValueError].} =
    #[Longest palindrome in a string by Manacher
      :param s: string, lowercase ascii, no whitespace
      :returns: indexes i,j such that s[i:j] is the longest palindrome in s
      :complexity: O(len(s))
      All the indexes refer to an intermediate string t
      of the form "^#a#b#a#a#$" for s="abaa"
    ]#
    if s.len == 0:
      raise newException(ValueError, "Empty string")
    let extraSymbols = toHashSet(['$', '^', '#'])
    let letters = toHashSet(s.toLowerAscii)
    assert disjoint(extraSymbols, letters) # Forbidden letters
    if s == "":
        return 0 .. 1
    let s = "^#" & join(s, "#") & "#$"
    var
      c = 1
      d = 1
      p = repeat(0, len(s))
    for i in 2 ..< len(s)-1:
        # reflect index i with respect to c
        let mirror = 2 * c - i         # = c - (i-c)
        p[i] = max(0, min(d - i, p[mirror]))
        # grow palindrome centered in i
        while s[i + 1 + p[i]] == s[i - 1 - p[i]]:
            p[i] += 1
        # adjust center if necessary
        if i + p[i] > d:
            c = i
            d = i + p[i]
    var
      k = 1
      j = 1
    for i in 1 ..< len(s):
      if k < p[i]:
        k = p[i]
        j = i
    return (j - k) div 2 ..< (j + k) div 2 # extract solution

func manacherString*(s: string): string {.raises: [ValueError].} =
  return s[manacher_index(s)]

func manacherLength*(s: string): int {.raises: [ValueError].} =
  let
    res = manacher_index(s)
    (i, j) = (res.a, res.b)
  return j - i + 1

when isMainModule:
  import std/unittest
  suite "Manacher's algorithm":
    test "Simple palindrome":
      check manacherIndex("abbbab") == 0 .. 4
      check manacherLength("abbbab") == 5
      check manacherString("abbbab") == "abbba"

    test "Only one letter palindrome":
      check manacherIndex("abcab") == 0 .. 0
      check manacherLength("abcab") == 1
      check manacherString("abcab") == "a"

    test "Palindrome is full string":
      check manacherIndex("telet") == 0 .. 4
      check manacherLength("telet") == 5
      check manacherString("telet") == "telet"
    
    test "Empty string":
      expect(ValueError):
        discard manacherIndex("")
      expect(ValueError):
        discard manacherLength("")
      expect(ValueError):
        discard manacherString("")

