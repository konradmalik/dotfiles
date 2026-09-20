final: prev:
{
  # nodejs_latest (26.x) fails its own test suite on build
  # (test/parallel/test-fs-cp-async-file-modes.mjs), so pin every consumer of
  # nodejs_latest (e.g. iosevka) to the default LTS nodejs until that is
  # fixed upstream.
  nodejs_latest = prev.nodejs;
}
