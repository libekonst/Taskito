//
//  EventPublisher.swift
//  Taskito
//
//  Created by Konstantinos Liberopoulos on 10/7/24.
//

import Combine
import Foundation

class EventPublisher<Event> {
    var subject = PassthroughSubject<Event, Never>()
    var handlers = Set<AnyCancellable>()

    func register(_ handler: @escaping (Event) -> Void) {
        subject.sink(receiveValue: handler).store(in: &handlers)
    }
    
    func publish(_ event: Event) {
        subject.send(event)
    }
}
