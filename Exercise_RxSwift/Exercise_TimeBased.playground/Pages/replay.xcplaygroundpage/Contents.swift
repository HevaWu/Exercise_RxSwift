import UIKit
import CoreGraphics
import RxSwift
import RxCocoa

let elementsPerSecond = 1
let maxElements = 5
let replayedElements = 1
let replayDelay: TimeInterval = 3

// records the last replayedElements emitted by the source observable
//let sourceObservable = Observable<Int>.create{ observer in
//    var value = 1
//    let timer = DispatchSource.timer(interval: 1.0/Double(elementsPerSecond), queue: .main) {
//        if value <= maxElements {
//            observer.onNext(value)
//            value = value + 1
//        }
//    }
//
//    return Disposables.create {
//        timer.suspend()
//    }
//    }
//    .replay(replayedElements)
let sourceObservable = Observable<Int>.interval(RxTimeInterval(1.0 / Double(elementsPerSecond)), scheduler: MainScheduler.instance)
    .replay(replayedElements)

let sourceTimeline = TimelineView<Int>.make()
let replayedTimeline = TimelineView<Int>.make()

let stack = UIStackView.makeVertical([
    UILabel.make("replay"),
    UILabel.make("Emit \(elementsPerSecond) per second:"),
    sourceTimeline,
    UILabel.make("Replay \(replayedElements) after \(replayDelay) sec:"),
    replayedTimeline
    ])

// replay(_:) creates a connectable observable, connect it to its underlying source to start receiving them
// connectable observable, --- until call connect(), they won't start emitting itemsConnCcoconrxs
_ = sourceObservable.subscribe(sourceTimeline)

// with a delay, elements received by the second subscription in another timeline view
DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) {
    _ = sourceObservable.subscribe(replayedTimeline)
}

// connectable observables need to call connect() method to ensure it is called
_ = sourceObservable.connect()

let hostView = setupHostView()
hostView.addSubview(stack)
hostView

extension CGPoint {
    func slope(to point: CGPoint) -> CGFloat {
        return (point.x - x) / (point.y - y)
    }
}

let p1 = CGPoint(x: 10e10, y: 10e10)
let p2 = CGPoint(x: 10e10, y: 15e10)
let p3 = CGPoint(x: 5e10, y: 10e10)
let p4 = CGPoint(x: 10e10, y: 5e10)
let p5 = CGPoint(x: 15e10, y: 10e10)

let slope12 = p1.slope(to: p2)
let slope13 = p1.slope(to: p3)
let slope14 = p1.slope(to: p4)
let slope15 = p1.slope(to: p5)

abs(CGFloat.infinity - CGFloat.infinity).isLess(than: 0.0001)
print(CGFloat.greatestFiniteMagnitude)
print(CGFloat.infinity)


// Support code -- DO NOT REMOVE
class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
    static func make() -> TimelineView<E> {
        return TimelineView(width: 400, height: 100)
    }
    public func on(_ event: Event<E>) {
        switch event {
        case .next(let value):
            add(.Next(String(describing: value)))
        case .completed:
            add(.Completed())
        case .error(_):
            add(.Error())
        }
    }
}


