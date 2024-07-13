use std::process::Command;

fn main() {
    let output = Command::new("hostname")
        .output()
        .expect("Failed to execute command");

    let hostname = String::from_utf8(output.stdout)
        .expect("Failed to read hostname")
        .trim()
        .to_string();

    println!("cargo:rustc-env=COMPUTER_NAME={}", hostname);
}
