import 'dart:math';

void main() {
  List<int> arr = [3, 1, 4, 2, 7, 5, 8, 6];
  // quickSort(arr, 0, arr.length - 1);
  quickSortWithRandomized(arr, 0, arr.length - 1);
  print(arr);
}

void quickSort(List<int> arr, int low, int high) {
  if (low < high) {
    int pi = partition(arr, low, high);
    quickSort(arr, low, pi - 1);
    quickSort(arr, pi + 1, high);
  }
}

int partition(List<int> arr, int low, int high) {
  int pivot = arr[high];
  int i = low - 1;
  for (int j = low; j < high; j++) {
    if (arr[j] < pivot) {
      i++;
      swap(arr, i, j);
    }
  }
  swap(arr, i + 1, high);
  return i + 1;
}

void swap(List<int> arr, int low, int high) {
  int temp = arr[low];
  arr[low] = arr[high];
  arr[high] = temp;
}

// optimisation
// 随机基准化
// 最优时间复杂度 O(nlogn), 最坏时间复杂度O(n^2)
// 最佳空间复杂大 O(logn), 最坏空间复杂度 O(n)
int randomizedPartition(List<int> arr, int low, int high) {
  int randomIndex = low + Random().nextInt(high - low + 1);
  swap(arr, randomIndex, high);
  return partition(arr, low, high);
}

void quickSortWithRandomized(List<int> arr, int low, int high) {
  if (low < high) {
    int pi = randomizedPartition(arr, low, high);
    quickSortWithRandomized(arr, low, pi - 1);
    quickSortWithRandomized(arr, pi + 1, high);
  }
}
