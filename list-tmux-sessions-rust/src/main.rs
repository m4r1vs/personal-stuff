use std::process::Command;
use std::str;
use std::sync::{Arc, Mutex};
use std::thread;

const ACTIVE_COLOR: &str = "#ee8000";
const INACTIVE_COLOR: &str = "#008e2f";
const DELIM: &str = "<span color='#6e767e'> 󰇙 </span>";
const COMPUTER_NAME: &str = env!("COMPUTER_NAME");

struct TmuxSession {
    id: i32,
    local_id: usize,
}

// Run a shell command and return the output
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

// Get the current tmux session ID. Unsafe is needed because we're using a static variable.
fn set_tmux_session_id() -> Result<i32, String> {
    static mut CURRENT_SESSION_ID: Option<i32> = None;
    unsafe {
        if CURRENT_SESSION_ID.is_none() {
            let result = run_command("tmux display-message -p '#S'")?;
            CURRENT_SESSION_ID = Some(result.parse::<i32>().map_err(|e| e.to_string())?);
        }
        CURRENT_SESSION_ID.ok_or_else(|| "Session ID not set".to_string())
    }
}

// Set the output string for each pane
fn set_output_string(
    session: &TmuxSession,
    pane_path: &str,
    pane_title: &str,
    pane_cmd: &str,
    pane_index: usize,
    output: &Mutex<Vec<String>>,
) {
    let color = if session.id == set_tmux_session_id().unwrap() {
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
        modified_pane_path = modified_pane_path.replace("/home/mn", "~");

        let folder_icon = if session.id == set_tmux_session_id().unwrap() {
            " "
        } else {
            " "
        };
        if !app_title.contains("zsh") {
            app_title = format!("{} @ ", app_title);
            app_title = app_title.replace("lazygit @ ", "󰊢 ");
        } else {
            app_title = app_title.replace("zsh", folder_icon);
        }
    } else {
        modified_pane_path = "".to_string();
        if app_title.contains(" - NVIM") {
            app_title = app_title.replace(" - NVIM", "");
            app_icon = " ".to_string();
        }
    }

    let output_string = format!(
        "{}<span color=\"{}\">{}{}{}</span>",
        delim, color, app_icon, app_title, modified_pane_path
    );

    output.lock().unwrap()[session.local_id].push_str(&output_string);
}

// Iterate over all panes in the given session and run set_output_string for each
fn set_tmux_panes(session: &TmuxSession, window_id: i32, output: &Arc<Mutex<Vec<String>>>) {
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
    output.lock().unwrap()[session.local_id].push_str("<br />");
}

// Get all tmux sessions and their panes
fn set_tmux_sessions() -> Vec<String> {
    let sessions_output = run_command("tmux ls -F '#S'").unwrap();
    let session_ids: Vec<i32> = sessions_output
        .split('\n')
        .filter_map(|s| s.parse().ok())
        .collect();

    let output = Arc::new(Mutex::new(Vec::new()));
    output
        .lock()
        .unwrap()
        .resize(session_ids.len(), String::new());

    let handles: Vec<_> = session_ids
        .iter()
        .enumerate()
        .map(|(local_id, &id)| {
            let output_clone = Arc::clone(&output);
            thread::spawn(move || {
                let session = TmuxSession { id, local_id };
                let windows_output =
                    run_command(&format!("tmux list-windows -t {} -F '#I'", id)).unwrap();
                let window_ids: Vec<i32> = windows_output
                    .split('\n')
                    .filter_map(|w| w.parse().ok())
                    .collect();

                for window_id in window_ids {
                    set_tmux_panes(&session, window_id, &output_clone);
                }
            })
        })
        .collect();

    for handle in handles {
        handle.join().unwrap();
    }

    Arc::try_unwrap(output).unwrap().into_inner().unwrap()
}

fn main() {
    let _ = set_tmux_session_id();
    let outputs = set_tmux_sessions();
    for output in outputs {
        println!("{}", output);
    }
}
