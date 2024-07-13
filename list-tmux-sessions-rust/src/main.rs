use std::process::Command;

use std::str;
use std::sync::{Arc, Mutex};
use std::thread;

const MAX_SESSIONS: usize = 12;
const ACTIVE_COLOR: &str = "#ee8000";
const INACTIVE_COLOR: &str = "#008e2f";
const DELIM: &str = "<span color='#6e767e'> 󰇙 </span>";
const COMPUTER_NAME: &str = env!("COMPUTER_NAME");

struct TmuxSession {
    id: i32,
    local_id: usize,
}

fn run_command(command: &str) -> Result<String, String> {
    let output = Command::new("sh")
        .arg("-c")
        .arg(command)
        .output()
        .map_err(|e| e.to_string())?;

    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).to_string());
    }

    Ok(String::from_utf8_lossy(&output.stdout).trim().to_string())
}

fn set_tmux_session_id() -> Result<i32, String> {
    let result = run_command("tmux display-message -p '#S'")?;
    result.parse::<i32>().map_err(|e| e.to_string())
}

fn set_output_string(
    session: &TmuxSession,
    pane_path: &str,
    pane_title: &str,
    pane_cmd: &str,
    pane_index: usize,
    output: &mut Vec<String>,
) {
    let color = if session.id == current_session_id() {
        ACTIVE_COLOR
    } else {
        INACTIVE_COLOR
    };

    let delim = if pane_index == 1 { "" } else { DELIM };
    let mut app_title = pane_title.to_string();
    let mut app_icon = "".to_string();

    let mut modified_pane_path = pane_path.to_string();

    // Check if pane title is the hostname, if so use pane_cmd
    if pane_title == COMPUTER_NAME {
        app_title = pane_cmd.to_string();
        modified_pane_path = replace_string(&modified_pane_path, "/home/mn", "~");

        let folder_icon = if session.id == current_session_id() {
            " "
        } else {
            " "
        };
        if !app_title.contains("zsh") {
            app_title = format!("{} @ ", app_title);
            app_title = replace_string(&app_title, "lazygit @ ", "󰊢 ");
        } else {
            app_title = replace_string(&app_title, "zsh", folder_icon);
        }
    } else {
        modified_pane_path = "".to_string();
        if app_title.contains(" - NVIM") {
            app_title = replace_string(&app_title, " - NVIM", "");
            app_icon = " ".to_string();
        }
    }

    let output_string = format!(
        "{}<span color=\"{}\">{}{}{}</span>",
        delim, color, app_icon, app_title, modified_pane_path
    );

    output[session.local_id].push_str(&output_string);
}

fn replace_string(original: &str, search: &str, replace: &str) -> String {
    original.replace(search, replace)
}

fn set_tmux_panes(session: &TmuxSession, window_id: i32, output: &mut Vec<String>) {
    // Double braces are used to escape the curly braces so they appear in the output string
    let command = format!(
        "tmux list-panes -t {}:{} -F '#{{pane_current_path}};#{{pane_current_command}};#{{pane_title}};#P'",
        session.id, window_id
    );
    if let Ok(panes_output) = run_command(&command) {
        let panes: Vec<&str> = panes_output.split('\n').collect();
        for (_pane_index, pane) in panes.iter().enumerate() {
            let details: Vec<&str> = pane.split(';').collect();
            if details.len() == 4 {
                let (pane_path, pane_cmd, pane_title, pane_index_str) =
                    (details[0], details[1], details[2], details[3]);
                let pane_index = pane_index_str.parse::<usize>().unwrap_or(0);
                set_output_string(session, pane_path, pane_title, pane_cmd, pane_index, output);
            }
        }
    }
    output[session.local_id].push_str("<br />");
}

fn set_tmux_sessions() -> Vec<String> {
    let sessions_output = run_command("tmux ls -F '#S'").unwrap();
    let session_ids: Vec<i32> = sessions_output
        .split('\n')
        .map(|s| s.parse().unwrap())
        .collect();

    let output = Arc::new(Mutex::new(vec![String::new(); MAX_SESSIONS]));

    let handles: Vec<_> = session_ids
        .iter()
        .enumerate()
        .map(|(local_id, &id)| {
            let output = Arc::clone(&output);
            thread::spawn(move || {
                let session = TmuxSession { id, local_id };
                let windows_output =
                    run_command(&format!("tmux list-windows -t {} -F '#I'", id)).unwrap();
                let window_ids: Vec<i32> = windows_output
                    .split('\n')
                    .map(|w| w.parse().unwrap())
                    .collect();

                for window_id in window_ids {
                    set_tmux_panes(&session, window_id, &mut output.lock().unwrap());
                }
            })
        })
        .collect();

    for handle in handles {
        handle.join().unwrap();
    }

    Arc::try_unwrap(output).unwrap().into_inner().unwrap()
}

fn current_session_id() -> i32 {
    set_tmux_session_id().unwrap()
}

fn main() {
    let _ = set_tmux_session_id();
    let outputs = set_tmux_sessions();
    for output in outputs {
        println!("{}", output);
    }
}
