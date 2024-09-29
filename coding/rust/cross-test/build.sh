# mkdir lib
# for ii in gdi32 kernel32 msimg32 opengl32 user32 winspool ; do cp /usr/x86_64-w64-mingw32/lib/lib$ii.a libwinapi_lib/$ii.a ; done

# cargo build --target x86_64-pc-windows-gnu --offline

RUSTFLAGS="-L native=$(pwd)/lib" cargo build --target x86_64-pc-windows-gnu --offline
