import 'quick_sort.dart';

// 三数取中法

int partitionWithMedianOfThree(List<int> arr, int low, int high) {
  int mid = low + ((high - low) ~/ 2);
  // 排序取中位数
  if (arr[low] > arr[mid]) {
    swap(arr, low, mid);
  }
  if (arr[low] > arr[high]) {
    swap(arr, low, high);
  }
  if (arr[mid] > arr[high]) {
    swap(arr, mid, high);
  }
  // 把中位数放在末尾（因为 partition 的轴心元素是从末尾开始取的）
  swap(arr, mid, high);
  return partition(arr, low, high);
}

void quickSortWithMedian(List<int> arr, int low, int high) {
  if (low < high) {
    int pi = partitionWithMedianOfThree(arr, low, high);
    quickSortWithMedian(arr, low, pi - 1);
    quickSortWithMedian(arr, pi + 1, high);
  }
}
