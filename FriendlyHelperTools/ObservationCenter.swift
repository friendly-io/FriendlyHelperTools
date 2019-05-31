//
//  ObservationCenter.swift
//  FriendlyHelperTools
//
//  Created by spsadmin on 5/31/19.
//

import Foundation

final class ObservationToken {
    private let cancellationClosure: () -> Void
    init(cancellationClosure: @escaping () -> Void) {
        self.cancellationClosure = cancellationClosure
    }
    func cancel() {
        cancellationClosure()
    }
}

final class ObservationCenter<ObservedType, EventType> {
    private var handlers = [UUID : (ObservedType, EventType) -> Void]()
    func notify(change: EventType,from observed: ObservedType) {
        handlers.values.forEach {
            $0(observed, change)
        }
    }
    @discardableResult
    func addObserver<T:AnyObject>(_ observer: T, onEvent: @escaping (T, ObservedType, EventType) -> Void) -> ObservationToken {
        let id = UUID()
        handlers[id] = { [weak self, weak observer] observed, change in
            guard let observer = observer else {
                self?.handlers.removeValue(forKey: id)
                return
            }
            onEvent(observer, observed, change)
        }
        return ObservationToken { [weak self] in
            self?.handlers.removeValue(forKey: id)
        }
    }
}

private extension Dictionary where Key == UUID {
    mutating func insert(_ value: Value) -> UUID {
        let id = UUID()
        self[id] = value
        return id
    }
}
