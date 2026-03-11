import 'dart:math';
import 'quick_sort.dart';

int partitionWithRandomized(List<int> arr, int low, int high) {
  int mid = low + Random().nextInt(high - low + 1);
  swap(arr, mid, high);
  return partition(arr, low, high);
}

void quickSortWithRandomized(List<int> arr, int low, int high) {
  if (low < high) {
    int pi = partitionWithRandomized(arr, low, high);
    partitionWithRandomized(arr, low, pi - 1);
    partitionWithRandomized(arr, pi + 1, high);
  }
}
