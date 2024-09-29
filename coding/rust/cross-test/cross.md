## Debian 官方仓库 Rust 交叉编译 Windows 二进制
## Cross-compile Windows binary using Rust and crates from Debian's offical apt repo


```bash
# 首先肯定是安装基础环境
# First install base env

apt install rust-all                    # basic rust toolchains
apt install libstd-rust-dev-windows     # rust stdlib for windows, this also installs basic mingw tools, should be enough ?
apt install librust-winapi-dev          # winapi crate
apt install mingw-w64                   # full mingw env, this seems uncessary

# 然后修改 Cargo.toml
# Modify Cargo.toml

# [dependencies]
# winapi = { version = "0.3.9", features = ["winuser"] }

# 修改 .cargo/config.toml
# Modify .cargo/config.toml

# [source]
# [source.debian-packages]
# directory = "/usr/share/cargo/registry"
# [source.crates-io]
# replace-with = "debian-packages"
#
# [target.x86_64-pc-windows-gnu]
# linker = "x86_64-w64-mingw32-gcc"

# winapi 似乎默认会链接一些改名后的库，本身的 winapi 仓库里面似乎是有的
# https://github.com/retep998/winapi-rs
# 但是 Debian 的 winapi 包里面似乎没有这些 lib
# 不过这些 lib 本身 mingw 好像是有提供的，只是名字不一样（内容一不一样不知道。。但是编译出来反正好像是能用的）

# winapi seems to trying to link some modified libs, these exists in the original github repo, but not in Debian's winapi package. Although these packages is provided by mingw-w64-x86-64-dev package, which is installed as dependency of libstd-rust-dev-windows

# 所以如果直接编译，会提示找不到各种 lib，一种解决方案是，在项目目录建一个 lib 目录，然后把需要用的 lib 全都改名并 copy 过来，然后在 rustflags 里面指定这个新目录
# 另一种方案的话，就是修改 winapi crate 的 build.rs 吧，但是我不会 ʅ（´◔౪◔）ʃ

# If run cargo build --target x86_64-pc-windows-gnu --offline directly, it will error, saying lib files not found. So one solution is to copy all the needed libs to a new local lib dir, and modify these names so linker can find them. Another is maybe modify winapi's build.rs, which i don't know how to...

# Anyway, it seems to be working now, without downloading anything from the Internet, just from a pure debian package.

```

