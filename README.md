# DotCorr Homebrew tap

DCDart 0.1.1 for macOS ARM64 and Linux x86-64/ARM64.

```sh
brew tap dotcorr/tap
brew trust --formula dotcorr/tap/dcdart
brew install dcdart
dcc --version
```

To upgrade: `brew update && brew upgrade dcdart`.

Requires Dart SDK **3.12.2** and Clang/LLVM for source compilation. Linux binaries require glibc 2.39+ (tested on Ubuntu 24.04). iOS/Android are output targets and additionally need Xcode/the Android NDK to link. This is the official DotCorr tap, not Homebrew core.

[Setup guide](https://dcdart.dotcorr.com/docs#setup) · [Release archives](https://github.com/DotCorr/dcdart/releases/tag/v0.1.1) · [Windows Scoop bucket](https://github.com/DotCorr/scoop-bucket)

Before changing the formula, verify the release asset checksums, perform a native compile/link/execute test, and update DCDart's website and release status together.
