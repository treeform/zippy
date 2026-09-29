import std/bitops, std/strformat, zippy

# One literal per copy, every byte value equally often, copy lengths with
# geometric frequencies. The Huffman code then gives 256 literals and one
# length code 9 bits each, with longer codes after them, so more than 255
# symbols share one code length. That count used to overflow a uint8 and the
# canonical codes for the longer lengths collided with the 9-bit codes.

const copyLengths = [5, 6, 7, 8, 9, 10, 11, 13, 15]

proc next(state: var uint32): uint32 =
  state = state xor (state shl 13)
  state = state xor (state shr 17)
  state = state xor (state shl 5)
  state

proc flatLiterals(len, seed: int): string =
  var
    state = 2463534242'u32 + seed.uint32 * 7919
    perm: array[256, uint8]
    p = 256
    k = 0
  for i in 0 ..< 256:
    perm[i] = i.uint8
  while result.len < len:
    if p == 256:
      for i in countdown(255, 1):
        swap(perm[i], perm[int(next(state) mod uint32(i + 1))])
      p = 0
    result.add char(perm[p])
    inc p
    inc k
    if result.len > 100:
      let
        repeat = copyLengths[min(countTrailingZeroBits(k), copyLengths.high)]
        start = result.len - 100
      for i in 0 ..< repeat:
        result.add result[start + i]
  result.setLen(len)

for size in [16384, 131072]:
  for seed in 0 .. 1:
    let original = flatLiterals(size, seed)
    for level in [-1, 2, 6, 7, 8, 9]:
      let
        compressed = compress(original, level)
        uncompressed = uncompress(compressed)
      echo &"Level {level} flat literals {size} seed {seed}: compressed {compressed.len}"
      doAssert original == uncompressed
