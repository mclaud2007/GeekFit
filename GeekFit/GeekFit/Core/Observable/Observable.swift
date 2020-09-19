//
//  Observable.swift
//  GeekFit
//
//  Created by Григорий Мартюшин on 19.09.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation

public struct ObservableOptions: OptionSet, CustomStringConvertible {
    
    public static let initial = ObservableOptions(rawValue: 1 << 0)
    public static let old = ObservableOptions(rawValue: 1 << 1)
    public static let new = ObservableOptions(rawValue: 1 << 2)
    
    public var rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public var description: String {
        switch self {
        case .initial:
            return "initial"
        case .old:
            return "old"
        case .new:
            return "new"
        default:
            return "ObservableOptions(rawValue: \(rawValue)"
        }
    }
}

public class OwnObservable<Type> {
    
    fileprivate class Callback {
        fileprivate weak var observer: AnyObject?
        fileprivate let options: [ObservableOptions]
        fileprivate let closure: (Type, ObservableOptions) -> Void
        
        fileprivate init(observer: AnyObject,
                         options: [ObservableOptions],
                         closure: @escaping (Type, ObservableOptions) -> Void) {
            self.observer = observer
            self.options = options
            self.closure = closure
        }
    }
    
    // MARK: - Properties
    public var value: Type {
        didSet {
            removeNilObserverCallbacks()
            notifyCallbacks(value: oldValue, option: .old)
            notifyCallbacks(value: value, option: .new)
        }
    }
    
    // MARK: - Managing Observers
    private var callbacks: [Callback] = []
    
    // MARK: - Object Lifecycle
    public init(_ value: Type) {
        self.value = value
    }
    
    public func addObservers(_ observer: AnyObject,
                             removeIfExists: Bool = true,
                             options: [ObservableOptions],
                             closure: @escaping (Type, ObservableOptions) -> Void) {
        if removeIfExists {
            removeObserver(observer)
        }
        
        // Создаем колбэк для нотификацый
        let callback = Callback(observer: observer, options: options, closure: closure)
        
        callbacks.append(callback)
        
        // Если подписаны на создание объекта - выполним замыкание
        if options.contains(.initial) {
            closure(value, .initial)
        }
    }
    
    public func removeObserver(_ observer: AnyObject) {
        callbacks = callbacks.filter { $0.observer !== observer }
    }
    
    private func removeNilObserverCallbacks() {
        callbacks = callbacks.filter { $0.observer != nil }
    }
    
    private func notifyCallbacks(value: Type, option: ObservableOptions) {
        let callbacksToNotify = callbacks.filter {
            $0.options.contains(option)
        }
        
        callbacksToNotify.forEach { $0.closure(value, option) }
    }
}
