/// [DropdownButtonFormField] 的通用数据项。
///
/// 用于替代页面中重复定义的私有 `_DropdownItem` 类。
class DropdownItem<T> {
  final T value;
  final String label;
  const DropdownItem({required this.value, required this.label});
}
