class Dcdart < Formula
  desc "Native systems language with Dart syntax — AOT to object files, ARC, C ABI"
  homepage "https://github.com/DotCorr/dcdart"
  url "https://github.com/DotCorr/dcdart/releases/download/v0.1.0/dcdart-v0.1.0-darwin-arm64.tar.gz"
  version "0.1.0"
  sha256 "edcc805741467462c2156a2dadc290cc964ba24aac804f039044348d729039d6"
  license "Apache-2.0" => { "with" => "LLVM-exception" }

  bottle do
    root_url "https://github.com/DotCorr/dcdart/releases/download/v0.1.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "3dc139c5b3ae944070c0a68d423300981547e63f5fdb85e6c07500b295fe85be"
  end

  depends_on arch: :arm64

  def install
    # The dcc binary resolves its default runtime prelude relative to its own
    # on-disk location, and the recognition of `@bare` compares the import URI
    # to that resolved path with exact lexical equality — symlinks are NOT
    # folded on either side (see core/dcc/lib/cli_args.dart in the repo). The
    # tarball ships the layout dcc expects (core/dcc/bin/dcc beside core/), so
    # the tree installs intact under libexec and `bin/dcc` is a symlink.
    #
    # Consequence: compile your own sources with an explicit
    #   --prelude #{opt_libexec}/core/runtime/dc-core-bare/prelude.dart
    # and import that same path (or spell it relative to your source and pass
    # the same spelling). The default resolution only works when the libexec
    # path is reached without a symlink hop — e.g. running the examples
    # inside #{opt_libexec}.
    # The release tarball wraps everything in a single top-level versioned
    # directory (dcdart-v0.1.0-darwin-arm64/). Unwrap it so the layout is
    # unconditionally <libexec>/core/…, then link the entrypoint.
    wrapper = Dir[libexec/"*"]
                 .select { |p| File.directory?(File.join(p, "core")) }
                 .first
    if wrapper
      inner = Pathname(wrapper).children
      libexec.rmtree
      libexec.install inner
    end
    bin.install_symlink libexec/"core/dcc/bin/dcc"
  end

  def caveats
    <<~EOS
      dcc compiles DCDart source to native object files with a plain C ABI.

      When compiling your own sources, pass the shipped prelude explicitly:

        dcc build --mode bare --target host main.dart -o main.o \\
          --prelude #{opt_libexec}/core/runtime/dc-core-bare/prelude.dart

      and use the same path in your source's import. (The prelude path is
      matched lexically, so it must be spelled the same on both sides.)

      Ready-to-run examples live in #{opt_libexec}/core/examples.
    EOS
  end

  test do
    # The compile smoke test needs a Dart SDK on PATH (the vendored 3.12.x the
    # project pins, or any dart satisfying its language version). Skip the
    # compile when absent — the binary itself is still exercised below.
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
