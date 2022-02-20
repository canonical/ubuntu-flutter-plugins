enum GtkIconLookupFlag {
  noSvg,
  forceSvg,
  useBuiltin,
  genericFallback,
  forceSize,
  forceRegular,
  forceSymbolic,
  dirLtr,
  dirRtl,
}

extension GtkIconLookupFlags on Set<GtkIconLookupFlag> {
  int toInt() {
    return fold<int>(0, (flags, flag) => flags | (1 << (flag.index + 1)));
  }
}
