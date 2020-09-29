//
//  Copyright © 2018 Rosberry. All rights reserved.
//

extension Collection {

    /// Returns collection of values at keyPaths of contained elements.
    func map<T>(by keyPath: KeyPath<Element, T>) -> [T] {
        map { innerElement -> T in
            innerElement[keyPath: keyPath]
        }
    }

    /// Returns collection of elements that are having value at certain keypath equal to value at keypath of passed element.
    func filter<T: Equatable>(by keyPath: KeyPath<Element, T>, of element: Element) -> [Element] {
        filter { innerElement -> Bool in
            innerElement[keyPath: keyPath] == element[keyPath: keyPath]
        }
    }

    /// Returns collection of elements that are having specific value at certain keypath.
    func filter<T: Equatable>(by value: T, at keyPath: KeyPath<Element, T>) -> [Element] {
        filter { innerElement -> Bool in
            innerElement[keyPath: keyPath] == value
        }
    }

    /// Returns collection of elements that has value at certain keypath that satisfies the given predicate.
    func filter<T: Equatable>(by keyPath: KeyPath<Element, T>, isIncluded: (T) -> Bool) -> [Element] {
        filter { innerElement -> Bool in
            isIncluded(innerElement[keyPath: keyPath])
        }
    }

    /// Returns first element in the collection that has value at certain keypath equal to value at keypath of passed element.
    func first<T: Equatable>(by keyPath: KeyPath<Element, T>, of element: Element) -> Element? {
        first { innerElement -> Bool in
            innerElement[keyPath: keyPath] == element[keyPath: keyPath]
        }
    }

    /// Returns first element in the collection that has specific value at certain keypath.
    func first<T: Equatable>(with value: T, at keyPath: KeyPath<Element, T>) -> Element? {
        first { innerElement -> Bool in
            innerElement[keyPath: keyPath] == value
        }
    }

    /// Checks if collection contains element that has value at certain keypath equal to value at keypath of passed element.
    func contains<T: Equatable>(by keyPath: KeyPath<Element, T>, of element: Element) -> Bool {
        contains { innerElement -> Bool in
            innerElement[keyPath: keyPath] == element[keyPath: keyPath]
        }
    }

    /// Checks if collection contains element that has specific value at certain keypath.
    func contains<T: Equatable>(with value: T, at keyPath: KeyPath<Element, T>) -> Bool {
        contains { innerElement -> Bool in
            innerElement[keyPath: keyPath] == value
        }
    }

    /// Returns index of element in the collection that has value at certain keypath equal to value at keypath of passed element.
    func index<T: Equatable>(by keyPath: KeyPath<Element, T>, of element: Element) -> Index? {
        firstIndex { innerElement -> Bool in
            innerElement[keyPath: keyPath] == element[keyPath: keyPath]
        }
    }

    /// Returns index of element in the collection that has specific value at certain keypath.
    func index<T: Equatable>(with value: T, at keyPath: KeyPath<Element, T>) -> Index? {
        firstIndex { innerElement -> Bool in
            innerElement[keyPath: keyPath] == value
        }
    }

    /// Returns the minimum element in the collection, using the given keyPath to get comparable property.
    func min<T: Comparable>(by keyPath: KeyPath<Element, T>) -> Element? {
        self.min { first, second -> Bool in
            first[keyPath: keyPath] < second[keyPath: keyPath]
        }
    }

    /// Returns the maximum element in the collection, using the given keyPath to get comparable property.
    func max<T: Comparable>(by keyPath: KeyPath<Element, T>) -> Element? {
        self.max { first, second -> Bool in
            first[keyPath: keyPath] < second[keyPath: keyPath]
        }
    }

    /// Returns the value of minimum element in the collection, using the given keyPath to get comparable property
    func mapMin<T: Comparable>(by keyPath: KeyPath<Element, T>) -> T? {
        let min = self.min(by: keyPath)
        return min?[keyPath: keyPath]
    }

    /// Returns the value of maximum element in the collection, using the given keyPath to get comparable property
    func mapMax<T: Comparable>(by keyPath: KeyPath<Element, T>) -> T? {
        let max = self.max(by: keyPath)
        return max?[keyPath: keyPath]
    }

    /// Returns collection of values at keyPaths of contained elements.
    func compactMap<T>(by keyPath: KeyPath<Element, T?>) -> [T] {
        compactMap { innerElement -> T? in
            innerElement[keyPath: keyPath]
        }
    }

    /// Checks if all collection elements has specific value at certain keypath.
    func isAll<T: Equatable>(with value: T, at keyPath: KeyPath<Element, T>) -> Bool {
        allSatisfy { innerElement -> Bool in
            innerElement[keyPath: keyPath] == value
        }
    }

    /// Returns sorted collection by comparator, using the given keyPath to get comparable property
    // swiftlint:disable:next identifier_name
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>, using comparator: (T, T) -> Bool = { f, s in f < s }) -> [Element] {
        sorted { first, second in
            comparator(first[keyPath: keyPath], second[keyPath: keyPath])
        }
    }

    /// Returns sorted collection by comparator, using the given keyPath to get comparable property
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T?>,
                               defaultValue: T,
                               // swiftlint:disable:next identifier_name
                               using comparator: (T, T) -> Bool = { f, s in f < s }) -> [Element] {
        sorted { first, second in
            comparator((first[keyPath: keyPath] ?? defaultValue), (second[keyPath: keyPath] ?? defaultValue))
        }
    }
}

extension MutableCollection where Self: RandomAccessCollection {
    /// Sort the collection by comparator, using the given keyPath to get comparable property
    // swiftlint:disable:next identifier_name
    mutating func sort<T: Comparable>(by keyPath: KeyPath<Element, T>, using comparator: (T, T) -> Bool = { f, s in f < s }) {
        sort { first, second in
            comparator(first[keyPath: keyPath], second[keyPath: keyPath])
        }
    }

    /// Sort the collection by comparator, using the given keyPath to get comparable property
    mutating func sort<T: Comparable>(by keyPath: KeyPath<Element, T?>,
                                      defaultValue: T,
                                      // swiftlint:disable:next identifier_name
                                      using comparator: (T, T) -> Bool = { f, s in f < s }) {
        sort { first, second in
            comparator((first[keyPath: keyPath] ?? defaultValue), (second[keyPath: keyPath] ?? defaultValue))
        }
    }
}
