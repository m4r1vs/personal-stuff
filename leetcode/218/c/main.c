#include <stdio.h>
#include <stdlib.h>

int **getSkyline(int **buildings, int buildingsSize, int *buildingsColSize,
                 int *returnSize, int **returnColumnSizes) {

  *returnSize = buildingsSize;
  // Allocate memory for returnColumnSizes and assign values
  *returnColumnSizes = (int *)malloc(buildingsSize * sizeof(int));
  for (int i = 0; i < buildingsSize; ++i) {
    (*returnColumnSizes)[i] = buildingsColSize[i];
  }
  return buildings;
}

#define ROWS 5
#define COLS 3
int main(int argc, char **argv) {

  int **buildings = (int **)malloc(ROWS * sizeof(int *));

  for (int i = 0; i < ROWS; i++) {
    buildings[i] = (int *)malloc(COLS * sizeof(int));
  }

  int data[ROWS][COLS] = {
      {2, 9, 10}, {3, 7, 15}, {5, 12, 12}, {15, 20, 10}, {19, 24, 8},
  };

  for (int i = 0; i < ROWS; i++) {
    for (int j = 0; j < COLS; j++) {
      buildings[i][j] = data[i][j];
    }
  }

  int buildingsColSize[ROWS] = {3, 3, 3, 3, 3};
  int *returnSize = (int *)malloc(sizeof(int));
  int **returnColumnSizes = (int **)malloc(ROWS * sizeof(int *));

  printf("Buildings:\n");
  for (int i = 0; i < ROWS; ++i) {
    printf("[");
    for (int j = 0; j < buildingsColSize[i]; ++j) {
      printf("%d", buildings[i][j]);
      if (j < buildingsColSize[i] - 1)
        printf(", ");
    }
    printf("]\n");
  }

  int **output = getSkyline(buildings, ROWS, buildingsColSize, returnSize,
                            returnColumnSizes);

  printf("Output:\n");
  for (int i = 0; i < *returnSize; ++i) {
    printf("[");
    for (int j = 0; j < *returnColumnSizes[i]; ++j) {
      printf("%d", output[i][j]);
      if (j < *returnColumnSizes[i] - 1)
        printf(", ");
    }
    printf("]\n");
  }

  return 0;
}
