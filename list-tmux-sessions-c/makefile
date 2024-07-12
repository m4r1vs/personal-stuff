CC=gcc
CFLAGS=-Wall -pthread

all: main

main: list-tmux-sessions.c
	$(CC) $(CFLAGS) -DHOSTNAME=\"$(shell hostname)\" -o tmuxls list-tmux-sessions.c

clean:
	rm -f tmuxls
