// The MIT License (MIT)
//
// Copyright (c) 2015-2022 Alexander Grebenyuk (github.com/kean).

import Foundation
import Combine

final class DataPublisher {
    let id: String
    private let _sink: (@escaping ((PublisherCompletion) -> Void), @escaping ((Data) -> Void)) -> Cancellable

    init<P: Publisher>(id: String, _ publisher: P) where P.Output == Data {
        self.id = id
        self._sink = { onCompletion, onValue in
            let cancellable = publisher.sink(receiveCompletion: {
                switch $0 {
                case .finished: onCompletion(.finished)
                case .failure(let error): onCompletion(.failure(error))
                }
            }, receiveValue: {
                onValue($0)
            })
            return AnonymousCancellable(cancellable.cancel)
        }
    }

    func sink(receiveCompletion: @escaping ((PublisherCompletion) -> Void), receiveValue: @escaping ((Data) -> Void)) -> Cancellable {
        _sink(receiveCompletion, receiveValue)
    }
}

enum PublisherCompletion {
    case finished
    case failure(Error)
}
