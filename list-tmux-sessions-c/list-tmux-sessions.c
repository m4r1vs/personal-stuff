#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SESSIONS 24
#define MAX_WINDOWS 24
#define MAX_PANES 8
#define MAX_BUFFER 2048

char *output[MAX_SESSIONS];
int current_session = 0;

struct tmux_session {
  int id;
  int local_id;
};

int run_command(const char *command, char *output, size_t maxlen) {
  FILE *fp;

  // Open the command for reading
  fp = popen(command, "r");
  if (fp == NULL) {
    perror("popen failed");
    return -1;
  }

  // Read the output a line at a time - output it
  if (fgets(output, maxlen - 1, fp) == NULL) {
    perror("fgets failed");
    pclose(fp);
    return -1;
  }

  // Close the stream
  if (pclose(fp) == -1) {
    perror("pclose failed");
    return -1;
  }

  // Trim the newline character from the output
  output[strcspn(output, "\n")] = '\0';

  return 0;
}

// Function to set the current tmux session ID
void set_tmux_session_id() {
  static char result[MAX_BUFFER];
  const char *command = "tmux display-message -p '#S'";

  if (run_command(command, result, sizeof(result)) == -1) {
    return;
  }

  current_session = strtol(result, NULL, 10);
}

void set_output_string(struct tmux_session session, char *pane_path,
                       char *pane_title, char *pane_cmd) {

  char *color = (session.id == current_session) ? "#ffffff" : "#000000";

  char pane_output_string[MAX_BUFFER];

  snprintf(pane_output_string, sizeof(pane_output_string),
           "<span foreground='%s'>Session: %d, Pane: %s, Title: %s, Command: "
           "%s</span>\n",
           color, session.id, pane_path, pane_title, pane_cmd);

  output[session.local_id] = pane_output_string;
}

void set_tmux_panes(struct tmux_session session, int window_id) {

  char command[MAX_BUFFER];
  char path[MAX_BUFFER];
  char *panes[MAX_PANES];

  int i = 0;

  snprintf(command, sizeof(command),
           "tmux list-panes -t %d:%d -F "
           "'#{pane_current_path};#{pane_current_command};#{pane_title}'",
           session.id, window_id);

  FILE *fp;
  fp = popen(command, "r");
  if (fp == NULL) {
    printf("Failed to run command\n");
    exit(1);
  }

  while (fgets(path, sizeof(path) - 1, fp) != NULL) {
    panes[i] = strdup(path);
    i++;
  }

  pclose(fp);

  for (int j = 0; j < i; j++) {

    char *pane_path = strtok(panes[j], ";");
    char *pane_cmd = strtok(NULL, ";");
    char *pane_title = strtok(NULL, ";");

    set_output_string(session, pane_path, pane_title, pane_cmd);

    free(panes[j]);
  }

  return;
}

void *print_tmux_windows(void *args) {
  struct tmux_session *session = (struct tmux_session *)args;

  char command[MAX_BUFFER];
  char path[MAX_BUFFER];
  char *windows[MAX_WINDOWS];

  int i = 0;

  snprintf(command, sizeof(command), "tmux list-windows -t %d -F '#I'",
           session->id);

  FILE *fp;
  fp = popen(command, "r");
  if (fp == NULL) {
    printf("Failed to run command\n");
    exit(1);
  }

  while (fgets(path, sizeof(path) - 1, fp) != NULL) {
    windows[i] = strdup(path);
    i++;
  }

  pclose(fp);

  for (int j = 0; j < i; j++) {
    set_tmux_panes(*session, strtol(windows[j], NULL, 10));
    free(windows[i]);
  }

  return NULL;
}

void set_tmux_sessions() {
  FILE *fp;
  char path[MAX_BUFFER];
  char *command = "tmux ls -F '#S'";
  int i = 0;

  struct tmux_session *sessions =
      malloc(MAX_SESSIONS * sizeof(struct tmux_session));

  fp = popen(command, "r");
  if (fp == NULL) {
    printf("Failed to run command\n");
    exit(1);
  }

  while (fgets(path, sizeof(path) - 1, fp) != NULL) {
    sessions[i].id = strtol(strdup(path), NULL, 10);
    sessions[i].local_id = i;
    output[i] = malloc(MAX_BUFFER * sizeof(char) * MAX_PANES);
    i++;
  }

  pclose(fp);

  pthread_t threads[i];

  for (int j = 0; j < i; j++) {
    pthread_create(&threads[j], NULL, print_tmux_windows, &sessions[j]);
  }

  for (int j = 0; j < i; j++) {
    pthread_join(threads[j], NULL);
    printf("%s", output[j]);
  }

  free(sessions);

  return;
}

int main() {
  set_tmux_session_id();
  set_tmux_sessions();
  return 0;
}
