use std::process::Command;

fn get_tmux_sessions() -> Vec<String> {
    let output = Command::new("/bin/tmux")
        .arg("list-sessions")
        .arg("-F")
        .arg("#S")
        .output()
        .expect("failed to execute process");

    let stdout = String::from_utf8_lossy(&output.stdout);
    let sessions: Vec<String> = stdout.lines().map(|s| s.to_string()).collect();
    sessions
}

fn get_tmux_windows(session: &str) -> Vec<String> {
    let output = Command::new("/bin/tmux")
        .arg("list-windows")
        .arg("-t")
        .arg(session)
        .arg("-F")
        .arg("#{window_name}")
        .output()
        .expect("failed to execute process");

    let stdout = String::from_utf8_lossy(&output.stdout);
    let windows: Vec<String> = stdout.lines().map(|s| s.to_string()).collect();
    windows
}

fn get_tmux_panes(session: &str, window: &str) -> Vec<String> {
    let output = Command::new("/bin/tmux")
        .arg("list-panes")
        .arg("-t")
        .arg(format!("{}:{}", session, window))
        .arg("-F")
        .arg("#P")
        .output()
        .expect("failed to execute process");

    let stdout = String::from_utf8_lossy(&output.stdout);
    let panes: Vec<String> = stdout.lines().map(|s| s.to_string()).collect();
    panes
}

fn main() {
    let sessions = get_tmux_sessions();
    for session in sessions {
        let windows = get_tmux_windows(&session);
        for window in windows {
            let panes = get_tmux_panes(&session, &window);
            for pane in panes {
                println!("{}:{}:{}", session, window, pane);
            }
        }
    }
}
