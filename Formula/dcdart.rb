class Dcdart < Formula
  desc "Native systems language with Dart syntax — AOT to object files, ARC, C ABI"
  homepage "https://github.com/DotCorr/dcdart"
  version "0.1.3"
  license "Apache-2.0" => { with: "LLVM-exception" }

  on_macos do
    depends_on arch: :arm64
    url "https://github.com/DotCorr/dcdart/releases/download/v0.1.3/dcdart-v0.1.3-darwin-arm64.tar.gz"
    sha256 "d36618d8311ef70b53cce9c0a11da5fafdcd86f06e9993852677ef0bfa418bbc"
  end
  on_linux do
    on_intel do
      url "https://github.com/DotCorr/dcdart/releases/download/v0.1.3/dcdart-v0.1.3-linux-x86_64.tar.gz"
      sha256 "b2e16a15196bdffd6eedcdfeaf6db616e4fc3f89fd8f12e0fee6958b96922c05"
    end
    on_arm do
      url "https://github.com/DotCorr/dcdart/releases/download/v0.1.3/dcdart-v0.1.3-linux-arm64.tar.gz"
      sha256 "4e4a48172b0756e90c1f770ca25daeb58280326b48aacc33a21efef1e45266e2"
    end
  end



  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"core/dcc/bin/dcc"
  end

  def caveats
    <<~EOS
      Linux archives were verified on Ubuntu 24.04 (glibc 2.39 or newer).
      Requires Dart SDK 3.12.2 and Clang/LLVM to compile source.
      Mobile targets also require Xcode or the Android NDK.
      dcc compiles DCDart source to native object files with a plain C ABI.

      When compiling your own sources, pass the shipped prelude explicitly:

        dcc build --mode bare --target host main.dart -o main.o \\
          --prelude #{opt_libexec}/core/runtime/dc-core-bare/prelude.dart

      and use the same path in your source's import. (The prelude path is
      matched lexically, so it must be spelled the same on both sides.)

      Setup and examples: https://dcdart.dotcorr.com/docs#setup
    EOS
  end

  test do
    assert_match "dcc 0.1.3", shell_output("#{bin}/dcc --version")
    # Source compilation requires exactly Dart SDK 3.12.2.
    dart = ENV["DCDART_DART"]
    dart = "dart" if dart.nil? || dart.empty?
    if which(dart)
      prelude = "#{libexec}/core/runtime/dc-core-bare/prelude.dart"
      path = testpath/"hello.dart"
      path.write <<~DCDART
        import '#{prelude}';

        @bare
        u64 sumTo(u64 n) {
          var i = u64(0);
          var total = u64(0);
          while (i < n) {
            total = total + i;
            i = i + u64(1);
          }
          return total;
        }
      DCDART
      system "#{bin}/dcc", "build", "--mode", "bare", "--target", "host",
                            path, "-o", testpath/"hello.o",
                            "--prelude", prelude
      assert_path testpath/"hello.o"
    else
      system "#{bin}/dcc", "--help"
    end
  end
end
