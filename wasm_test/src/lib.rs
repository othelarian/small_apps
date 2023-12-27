//extern crate console_error_panic_hook;

use wasm_bindgen::prelude::*;

pub fn set_panic_hook() {
    #[cfg(feature = "console_error_panic_hook")]
    console_error_panic_hook::set_once();
}

#[wasm_bindgen]
extern "C" {
  fn alert(s: &str);

  #[wasm_bindgen(js_namespace = console)]
  fn log(s: &str);
}

#[wasm_bindgen]
pub fn greet(name: &str) {
  set_panic_hook();
  //
  log("we are in greet");
  log(name);
  //
  alert(&format!("Hello, {}!", name));
}