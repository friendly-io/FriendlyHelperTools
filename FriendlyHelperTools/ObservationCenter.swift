// <origin src="https://github.com/friendly-io/FriendlyHelperTools/raw/master/FriendlyHelperTools/ObservationCenter.swift" />
//
//  Observation.swift
//  friendlyAppKit
//
//  Created by spsadmin on 3/4/19.
//  Copyright © 2019 Friendly App Studio. All rights reserved.
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
        DispatchQueue.main.async {
            self.handlers.values.forEach {
                $0(observed, change)
            }
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
