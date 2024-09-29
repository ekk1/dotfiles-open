extern crate winapi;

use std::ptr::null_mut;
use winapi::um::winuser::{MessageBoxW, MB_OK};

fn main() {
    unsafe {
        let text = widestring("Hello, World!");
        let caption = widestring("Greetings");

        MessageBoxW(
            null_mut(),
            text.as_ptr(),
            caption.as_ptr(),
            MB_OK,
        );
    }
}

fn widestring(value: &str) -> Vec<u16> {
    use std::ffi::OsStr;
    use std::os::windows::ffi::OsStrExt;
    OsStr::new(value).encode_wide().chain(Some(0).into_iter()).collect()
}

