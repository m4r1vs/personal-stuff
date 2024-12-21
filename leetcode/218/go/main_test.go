package main

import (
	"reflect"
	"testing"
)

func TestGetSkyline(t *testing.T) {
	buildings := [5][3]int{{2, 9, 10}, {3, 7, 15}, {5, 12, 12}, {15, 20, 10}, {19, 24, 8}}
	expectedSkyline := [7][2]int{{2, 10}, {3, 15}, {7, 12}, {12, 0}, {15, 10}, {20, 8}, {24, 0}}

	var buildingsSlice [][]int
	for _, b := range buildings {
		buildingsSlice = append(buildingsSlice, b[:])
	}

	var expectedSkylineSlice [][]int
	for _, b := range expectedSkyline {
		expectedSkylineSlice = append(expectedSkylineSlice, b[:])
	}

	actualSkyline := GetSkyline(buildingsSlice)

	if !reflect.DeepEqual(actualSkyline, expectedSkylineSlice) {
		t.Errorf("Test failed: expected %v, got %v", expectedSkyline, actualSkyline)
	}
}
