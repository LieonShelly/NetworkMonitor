void swap(List<int> arr, int low, int high) {
  int temp = arr[low];
  arr[low] = arr[high];
  arr[high] = temp;
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

void quickSort(List<int> arr, int low, int high) {
  if (low < high) {
    int pi = partition(arr, low, high);
    quickSort(arr, low, pi - 1);
    quickSort(arr, pi + 1, high);
  }
}

void main() {
  List<int> arr = [10, 7, 8, 9, 1, 5];
  print("排序前的数组:$arr");
  quickSort(arr, 0, arr.length - 1);
  print("排序后的数组: $arr");
}
