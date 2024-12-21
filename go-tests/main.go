package main

import (
	"fmt"
	"sync"
)

func Hello() string {
	return "Hello, world!"
}

func main() {
	helloGoRoutines(32)
}

func helloGoRoutines(n int) {
	var wg sync.WaitGroup // Create a WaitGroup

	for k := 0; k < n; k++ {
		wg.Add(1) // Increment the WaitGroup counter for each goroutine
		go calcsubterm(k, &wg)
	}

	wg.Wait() // Wait for all goroutines to complete
}

func calcsubterm(k int, wg *sync.WaitGroup) {
	defer wg.Done() // Decrement the counter when the goroutine completes
	fmt.Println(k)
}
