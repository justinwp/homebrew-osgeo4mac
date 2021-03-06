class Ossim < Formula
  desc "Geospatial libs and apps to process imagery, terrain, and vector data"
  homepage "https://trac.osgeo.org/ossim/"

  stable do
    url "https://github.com/ossimlabs/ossim/archive/Hollywood-2.4.0.tar.gz"
    sha256 "73d59cdfe09f220c9847f9c366b28bd6cf548d4acb0c28ac3800280999bd6d2f"
  end

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    rebuild 1
    sha256 "620f012a2e84694de2b7413fe138a14af369f995a9bdbe1d2d358e28f03a5689" => :high_sierra
    sha256 "620f012a2e84694de2b7413fe138a14af369f995a9bdbe1d2d358e28f03a5689" => :sierra
  end

  option "with-curl-apps", "Build curl-dependent apps"
  option "without-framework", "Generate library instead of framework"
  option "with-gui", "Build new ossimGui library and geocell application"

  depends_on "cmake" => :build
  depends_on "open-scene-graph" # just for its OpenThreads lib
  depends_on "jpeg"
  depends_on "jsoncpp"
  depends_on "libtiff"
  depends_on "libgeotiff"
  depends_on "geos"
  depends_on "freetype"
  depends_on "zlib"
  depends_on "open-mpi" => :optional

  def install
    ENV.cxx11

    ENV["OSSIM_DEV_HOME"] = buildpath.to_s
    ENV["OSSIM_BUILD_DIR"] = (buildpath/"build").to_s
    ENV["OSSIM_INSTALL_PREFIX"] = prefix.to_s

    # TODO: add options and deps for plugins
    args = std_cmake_args + %W[
      -DOSSIM_DEV_HOME=#{ENV["OSSIM_DEV_HOME"]}
      -DINSTALL_LIBRARY_DIR=lib
      -DBUILD_OSSIM_APPS=ON
      -DBUILD_OMS=OFF
      -DBUILD_CNES_PLUGIN=OFF
      -DBUILD_GEOPDF_PLUGIN=OFF
      -DBUILD_GDAL_PLUGIN=OFF
      -DBUILD_HDF5_PLUGIN=OFF
      -DBUILD_KAKADU_PLUGIN=OFF
      -DBUILD_KML_PLUGIN=OFF
      -DBUILD_MRSID_PLUGIN=OFF
      -DMRSID_DIR=
      -DOSSIM_PLUGIN_LINK_TYPE=SHARED
      -DBUILD_OPENCV_PLUGIN=OFF
      -DBUILD_OPENJPEG_PLUGIN=OFF
      -DBUILD_PDAL_PLUGIN=OFF
      -DBUILD_PNG_PLUGIN=OFF
      -DBUILD_POTRACE_PLUGIN=OFF
      -DBUILD_SQLITE_PLUGIN=OFF
      -DBUILD_WEB_PLUGIN=OFF
      -DBUILD_OSSIM_VIDEO=OFF
      -DBUILD_OSSIM_WMS=OFF
      -DBUILD_OSSIM_PLANET=OFF
      -DOSSIM_BUILD_ADDITIONAL_DIRECTORIES=
      -DBUILD_OSSIM_TESTS=OFF
    ]

    args << "-DBUILD_OSSIM_FRAMEWORKS=" + (build.with?("framework") ? "ON" : "OFF")
    args << "-DBUILD_OSSIM_MPI_SUPPORT=" + (build.with?("mpi") ? "ON" : "OFF")
    args << "-DBUILD_OSSIM_CURL_APPS=" + (build.with?("curl-apps") ? "ON" : "OFF")
    args << "-DBUILD_OSSIM_GUI=" + (build.with?("gui") ? "ON" : "OFF")

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    system bin/"ossim-cli", "--version"
  end
end
