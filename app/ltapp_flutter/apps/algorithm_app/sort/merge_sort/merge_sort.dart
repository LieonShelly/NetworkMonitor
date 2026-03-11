void mergeSort(List<int> arr, int left, int right) {
  if (left < right) {
    int mid = left + ((right - left) ~/ 2);
    mergeSort(arr, left, mid);
    mergeSort(arr, mid + 1, right);
    merge(arr, left, mid, right);
  }
}

void merge(List<int> arr, int left, int mid, int right) {
  // 计算左右两个临时子数组的长度
  int n1 = mid - left + 1;
  int n2 = right - mid;

  List<int> leftArr = List.filled(n1, 0);
  List<int> rightArr = List.filled(n2, 0);

  // 将原数组中的数据拷贝到临时数组中
  for (int i = 0; i < n1; i++) {
    leftArr[i] = arr[left + i];
  }

  for (int j = 0; j < n2; j++) {
    rightArr[j] = arr[mid + 1 + j];
  }

  int i = 0;
  int j = 0;
  int k = left;

  // 当左右两个数组都有元素时，比较大小，小的先入列
  while (i < n1 && j < n2) {
    if (leftArr[i] <= rightArr[j]) {
      arr[k] = leftArr[i];
      i++;
    } else {
      arr[k] = rightArr[j];
      j++;
    }
    k++;
  }

  // 扫尾工作：如果左数组还有剩余，直接全部追加到后面
  while (i < n1) {
    arr[k] = leftArr[i];
    i++;
    k++;
  }
  // 扫尾工作：如果右数组还有剩余，直接全部追加到后面
  while (j < n2) {
    arr[k] = rightArr[j];
    j++;
    k++;
  }
}
