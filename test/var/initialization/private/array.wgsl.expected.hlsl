struct tint_array_wrapper {
  int arr[3];
};

static tint_array_wrapper v = (tint_array_wrapper)0;

[numthreads(1, 1, 1)]
void main() {
  v;
  return;
}
