package main

import (
	"container/heap"
	"sort"
)

func GetSkyline(buildings [][]int) [][]int {

	var points PriorityQueue

	for _, building := range buildings {
		start, end := toItems(building[0], building[1], building[2])
		points = append(points, start, end)
	}

	sort.Slice(points, func(i, j int) bool {
		switch {
		case points[i].x != points[j].x:
			return points[i].x < points[j].x
		case points[i].side != points[j].side:
			return points[i].side == Left
		case points[i].side == Left:
			return points[i].priority > points[j].priority
		default:
			return points[i].priority < points[j].priority
		}
	})

	var p PriorityQueue
	heap.Init(&p)

	var results [][]int
	lastHeight := 0
	for _, point := range points {
		if point.side == Left {
			heap.Push(&p, point)
			if lastHeight != p.Peek() {
				results = append(results, []int{point.x, p.Peek()})
				lastHeight = p.Peek()
			}
			continue
		}
		// if end
		heap.Remove(&p, point.ref.index)
		h := 0
		if p.Len() > 0 {
			h = p.Peek()
		}

		if lastHeight != h {
			results = append(results, []int{point.x, h})
			lastHeight = h
		}
	}

	return results
}

func toItems(start, end, height int) (*Item, *Item) {
	s := &Item{
		x:        start,
		side:     Left,
		priority: height,
	}

	e := &Item{
		x:        end,
		side:     Right,
		priority: height,
		ref:      s,
	}
	return s, e
}

type Position int

const (
	Left Position = iota
	Right
)

type Item struct {
	side     Position
	ref      *Item
	x        int
	value    int
	priority int

	index int
}

type PriorityQueue []*Item

func (pq PriorityQueue) Len() int { return len(pq) }

func (pq PriorityQueue) Less(i, j int) bool {

	return pq[i].priority > pq[j].priority
}

func (pq PriorityQueue) Swap(i, j int) {
	pq[i], pq[j] = pq[j], pq[i]
	pq[i].index = i
	pq[j].index = j
}

func (pq *PriorityQueue) Push(x any) {
	n := len(*pq)
	item := x.(*Item)
	item.index = n
	*pq = append(*pq, item)
}

func (pq PriorityQueue) Peek() int {
	return pq[0].priority

}

func (pq *PriorityQueue) Pop() any {
	old := *pq
	n := len(old)
	item := old[n-1]
	old[n-1] = nil
	item.index = -1
	*pq = old[0 : n-1]
	return item
}

func (pq *PriorityQueue) Update(item *Item, value int, priority int) {
	item.value = value
	item.priority = priority
	heap.Fix(pq, item.index)
}
