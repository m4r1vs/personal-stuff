package main

import (
	"database/sql"
	"fmt"

	_ "github.com/mattn/go-sqlite3"
)

func main() {
	fmt.Println("Hello, SQLite!")

	db, err := sql.Open("sqlite3", "./test.db")

	if err != nil {
		panic(err)
	}

	defer db.Close()
}
