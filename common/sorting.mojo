
fn selection_sort(inout arr: DynamicVector[Int]):
    for i in range(len(arr)):
        for j in range(i, len(arr)):
            if arr[j] < arr[i]:
                let tmp = arr[i]
                arr[i] = arr[j]
                arr[j] = tmp