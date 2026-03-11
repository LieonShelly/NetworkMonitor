import 'dart:math';

void main() {
  List<int> arr = [3, 1, 4, 2, 7, 5, 8, 6];
  // quickSort(arr, 0, arr.length - 1);
  // quickSortWithRandomized(arr, 0, arr.length - 1);
  quickSortMedian(arr, 0, arr.length - 1);
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

// 三数选中法
void quickSortMedian(List<int> arr, int low, int high) {
  if (low < high) {
    int pi = paritionWithMedianOfThree(arr, low, high);
    quickSortMedian(arr, low, pi - 1);
    quickSortMedian(arr, pi + 1, high);
  }
}

int paritionWithMedianOfThree(List<int> arr, int low, int high) {
  // 计算出中间位置的索引
  int mid = low + ((high - low) ~/ 2);

  // 对 arr[low], arr[mid], arr[high] 进行手动排序
  // 目标是让这三个位置的元素满足 arr[low] < arr[mid] < arr[high]
  if (arr[low] > arr[mid]) {
    swap(arr, low, mid);
  }
  if (arr[low] > arr[high]) {
    swap(arr, low, high);
  }
  if (arr[mid] > arr[high]) {
    swap(arr, mid, high);
  }

  // 经过上面 3 次比较和交换，arr[mid] 绝对是这三个数中的中位数了
  // 同时，arr[low] 肯定小于等于中位数， arr[high] 肯定大于等于中位数

  // 我们把找到的中位数（基准）交换到数组的末尾
  // 这样就可以完美复用我们最基础的标准 partition 逻辑了
  swap(arr, mid, high);

  return partition(arr, low, high);
}
