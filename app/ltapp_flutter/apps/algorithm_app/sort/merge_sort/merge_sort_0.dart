// 分而治之，单个元素的数组默认有序
// 时间复杂度 O(nlogn) 空间复杂度 O(n)
void mergeSort(List<int> arr, int left, int right) {
  if (left < right) {
    int mid = left + (right - left) ~/ 2;
    mergeSort(arr, left, mid);
    mergeSort(arr, mid + 1, right);
    merge(arr, left, mid, right);
  }
}

void merge(List<int> arr, int left, int mid, int right) {
  int n1 = mid - left + 1;
  int n2 = right - mid;
  List<int> leftArr = List<int>.filled(n1, 0);
  List<int> rightArr = List<int>.filled(n2, 0);
  int i = 0;
  int j = 0;
  int k = left;

  for (int i = 0; i < n1; i++) {
    leftArr[i] = arr[left + i];
  }
  for (int i = 0; i < n2; i++) {
    rightArr[i] = arr[mid + 1 + i];
  }
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

  while (i < n1) {
    arr[k] = leftArr[i];

    i++;
    k++;
  }

  while (j < n2) {
    arr[k] = rightArr[j];
    k++;
    j++;
  }
}
