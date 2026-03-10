void main() {
  List<int> arr = [10, 7, 8, 9, 1, 5];
  print("排序前的数组:$arr");
  quickSort(arr, 0, arr.length - 1);
  print("排序后的数组: $arr");
}

void quickSort(List<int> arr, int low, int high) {
  if (low < high) {
    // pi 是分区后基准元素的正确索引位置
    int pi = partition(arr, low, high);

    // 分治法：递归对基准元素左边的子数组进行排序
    quickSort(arr, low, pi - 1);

    // 分治法：递归对基准元素右边的子数组进行排序
    quickSort(arr, pi + 1, high);
  }
}

// 分区函数，负责把小于基准的放左边，大于的放右边
int partition(List<int> arr, int low, int high) {
  // 我们选择最右边的元素作为基准
  int pivot = arr[high];

  // i 用来追踪 "较小元素" 的最后位置
  int i = low - 1;

  for (int j = low; j < high; j++) {
    if (arr[j] <= pivot) {
      i++; // 较小元素的区域扩大
      swap(arr, i, j); // 将当前元素交换到较小元素的区域中
    }
  }
  // 遍历结束后，把基准元素 arr[high] 放到中间 (i + 1的位置)
  swap(arr, i + 1, high);

  // 返回基准元素最终的所在的位置
  return i + 1;
}

// 辅助函数：交换数组中的两个元素
void swap(List<int> arr, int i, int j) {
  int temp = arr[i];
  arr[i] = arr[j];
  arr[j] = temp;
}
