/// Returns the first item in [items] whose id (per [idOf]) matches [id],
/// or `null` if none match. Shared by the controllers' `xById` lookups.
T? findById<T>(List<T> items, String id, String Function(T item) idOf) {
  for (final T item in items) {
    if (idOf(item) == id) return item;
  }
  return null;
}
