#include <iostream>
#include <vector>

using namespace std;

void PrintArr(vector<int>& arr) {
	for (int i : arr) {
		cout << i << " ";
	}
	cout << endl;
}

void QuickSort(vector<int>& arr, int left, int right) {
	if (left >= right)
		return;


	/*int middle = (left + right) / 2;*/
	int middle = arr[right];

	int i = left, j = right;

	while (i < j) {
		while (arr[i] < middle) i++;
		while (arr[j] > middle) j--;

		if (i <= j) {
			int temp = arr[i];
			arr[i] = arr[j];
			arr[j] = temp;
			
			i++;
			j--;
		}

		
	}

	//PrintArr(arr);

	if (left < j)
		QuickSort(arr, left, j);
	if (right > i)
		QuickSort(arr, i, right);

}



int main() {
	vector<int> arr = { 1,13,-4,5 };
	QuickSort(arr, 0, arr.size() - 1);
	PrintArr(arr);
}