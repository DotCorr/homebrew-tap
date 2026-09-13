class Dcdart < Formula
  desc "Native systems language with Dart syntax — AOT to object files, ARC, C ABI"
  homepage "https://github.com/DotCorr/dcdart"
  version "0.1.2"
  license "Apache-2.0" => { "with" => "LLVM-exception" }

  on_macos do
    depends_on arch: :arm64
    url "https://github.com/DotCorr/dcdart/releases/download/v0.1.2/dcdart-v0.1.2-darwin-arm64.tar.gz"
    sha256 "048867864ba94c47be983fb6b3c2c95709d9a5780c08bcf36de6cf4b61514ec2"
  end
  on_linux do
    on_intel do
      url "https://github.com/DotCorr/dcdart/releases/download/v0.1.2/dcdart-v0.1.2-linux-x86_64.tar.gz"
    sha256 "9347a04f03885a2686fc7fac2e857954bc9d9cb2a42bcbf92a1fac84c2a33afe"
    end
    on_arm do
      url "https://github.com/DotCorr/dcdart/releases/download/v0.1.2/dcdart-v0.1.2-linux-arm64.tar.gz"
    sha256 "bc835bf35a36897c7267e26f2d952a71a81f7e0438ca4f532a54cb5e2c1dcb8f"
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
    assert_match "dcc 0.1.2", shell_output("#{bin}/dcc --version")
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
