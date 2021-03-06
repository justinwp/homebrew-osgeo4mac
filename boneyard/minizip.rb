require 'formula'

class Minizip < Formula
  homepage 'http://www.winimage.com/zLibDll/minizip.html'
  url 'http://zlib.net/zlib-1.2.8.tar.gz'
  sha1 'a4d316c404ff54ca545ea71a27af7dbc29817088'

  # version for minizip, not zlib
  version '1.1'

  option :universal

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def patches
    # configure script fails to detect the right compiler when "cc" is
    # clang, not gcc.
    # see: https://github.com/Homebrew/homebrew-dupes/pull/228
    #      https://github.com/madler/zlib/pull/54
    DATA
  end

  def install
    ENV.universal_binary if build.universal?
    system './configure', "--prefix=#{prefix}"
    system 'make'

    cd 'contrib/minizip' do
      # edits to statically link to libz.a
      inreplace 'Makefile.am' do |s|
        s.sub! '-L$(zlib_top_builddir)', '$(zlib_top_builddir)/libz.a'
        s.sub! '-version-info 1:0:0 -lz', '-version-info 1:0:0'
        s.sub! 'libminizip.la -lz', 'libminizip.la'
      end
      system 'autoreconf', '-fi'
      system './configure', "--prefix=#{prefix}"
      system 'make install'
    end

  end

  def caveats
    <<~EOS
      Minizip headers installed in 'minizip' subdirectory, since they conflict
      with the venerable 'unzip' library.
    EOS
  end
end

__END__
diff --git a/configure b/configure
index b77a8a8..54f33f7 100755
--- a/configure
+++ b/configure
@@ -159,6 +159,7 @@ case "$cc" in
 esac
 case `$cc -v 2>&1` in
   *gcc*) gcc=1 ;;
+  *clang*) gcc=1 ;;
 esac

 show $cc -c $test.c
