import std/os, zippy/ziparchives, std/tables, std/strutils

when (NimMajor, NimMinor, NimPatch) >= (1, 6, 0):
  var entries: OrderedTable[string, string]
  entries["README.txt"] = "Hello, World!"

  let archive = createZipArchive(entries)
  echo archive.len
  # writeFile("tmp.zip", archive)

  # A payload that fits the classic format must produce a classic (non-ZIP64)
  # archive: no ZIP64 end-of-central-directory record, whose signature
  # (0x06064b50) would otherwise appear in the output.
  doAssert not archive.contains("\x50\x4b\x06\x06"), "expected a classic archive"

  # And it must round-trip back through the reader.
  var written: OrderedTable[string, string]
  written["dir/file.txt"] = "Hello, World!"
  written["empty.txt"] = ""
  let roundTripped = createZipArchive(written)
  doAssert not roundTripped.contains("\x50\x4b\x06\x06")
  writeFile(getTempDir() / "zippy_classic_roundtrip.zip", roundTripped)
  let reader = openZipArchive(getTempDir() / "zippy_classic_roundtrip.zip")
  try:
    doAssert reader.extractFile("dir/file.txt") == "Hello, World!"
    doAssert reader.extractFile("empty.txt") == ""
  finally:
    reader.close()
  removeFile(getTempDir() / "zippy_classic_roundtrip.zip")

  # let reader = openZipArchive("tmp.zip")

  # try:
  #   # Iterate over the paths in the zip archive.
  #   for path in reader.walkFiles:
  #     echo path

  #   # # Extract a file from the archive.
  #   # let contents = reader.extractFile("tmp.txt")
  #   # echo contents.len
  # finally:
  #   # Remember to close the reader when done.
  #   reader.close()

  # var entries: OrderedTable[string, string]
  # for path in walkDirRec(getCurrentDir(), relative = true, skipSpecial = true):
  #   if path.startsWith(".git"):
  #     continue
  #   if path.endsWith(".exe"):
  #     continue
  #   entries[path] = readFile(path)
  # writeFile("tmp.zip", createZipArchive(entries))

  # let reader = openZipArchive("tmp.zip")

  # try:
  #   # Iterate over the paths in the zip archive.
  #   for path in reader.walkFiles:
  #     echo path

  # finally:
  #   # Remember to close the reader when done.
  #   reader.close()
