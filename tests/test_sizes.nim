import zippy/[inflate, ziparchives]

block:
  # The ZIP declares one byte but actually expands to 4096 bytes.
  let archive = openZipArchive("tests/data/ziparchives/understated-size.zip")
  defer: archive.close()
  doAssert archive.getFileSize("payload") == 4096
  doAssert archive.getFileSize("payload") == archive.extractFile("payload").len
  doAssertRaises(ZippyError):
    discard archive.getFileSize("missing")
  doAssert inflateSize(nil, 0) == -1
  doAssert inflateSize(nil, -1) == -1
