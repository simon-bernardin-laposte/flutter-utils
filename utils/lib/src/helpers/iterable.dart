Iterable<T> compactIterable<T>(Iterable<T> iterable) =>
    iterable.where((elt) => elt != null);

List<T> compactList<T>(Iterable<T> iterable) =>
    compactIterable(iterable).toList();

T? ensureInIterable<T>(Iterable<T> list, T value) =>
    list.contains(value) ? value : null;
