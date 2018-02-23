//: Playground - noun: a place where people can play

import UIKit
import RxSwift

example(of: "startWith") {
    let numbers = Observable.of(2, 3, 4)

    //startWith create emits the initial value
    let observable = numbers.startWith(1)
    observable.subscribe(onNext: {
        print($0)
    })
}

example(of: "Observable.concat") {
    let first = Observable.of(1, 2, 3)
    let second = Observable.of(4, 5, 6)

    let observable = Observable.concat([first, second])
    observable.subscribe(onNext: {
        print($0)
    })

    //another way to concat two observables
    let germanCities = Observable.of("Berlin", "Münich", "Frankfurt")
    let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")

    let observable2 = germanCities.concat(spanishCities)
    observable2.subscribe(onNext: {
        print($0)
    })
}

example(of: "concatMap") {
    let sequences = [
        "Germany": Observable.of("Berlin", "Münich", "Frankfurt"),
        "Spain": Observable.of("Madrid", "Barcelona", "Valencia")
    ]

    let observable = Observable.of("Germany", "Spain")
        .concatMap { country in sequences[country] ?? .empty() }

    _ = observable.subscribe(onNext: {
        print($0)
    })
}

example(of: "merge") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    let middle = PublishSubject<String>()

    let source = Observable.of(left.asObservable(), right.asObservable(), middle.asObservable())

    //"merge" subscribes to each of the sequences it receives and emits the element as soon as they arrive
    //if want to limit the number of sequences subscribed, could use "merge(maxConcurrent:)", and if it reaches maxConcurrent,
    //put incoming observables in a queue, and subscribe them in order, as soon as one of the current sequences completes
    let observable = source.merge(maxConcurrent: 2)
    let disposable = observable.subscribe(onNext: {
        print($0)
    })

    var leftValues = ["Berlin", "Munich", "Frankfurt"]
    var rightValues = ["Madrid", "Barcelona", "Valencia"]
    var middleValues = ["1", "2", "3"]

    repeat {
        if !(!leftValues.isEmpty && !rightValues.isEmpty) {
            if !middleValues.isEmpty {
                middle.onNext("Middle: " + middleValues.removeFirst())
            }
        }

        if arc4random_uniform(2) == 0 {
            if !leftValues.isEmpty {
                left.onNext("Left: " + leftValues.removeFirst())
            } else {
                left.onCompleted()
            }
        } else if !rightValues.isEmpty {
            right.onNext("Right: " + rightValues.removeFirst())
        } else {
            right.onCompleted()
        }
    } while !leftValues.isEmpty || !rightValues.isEmpty || !middleValues.isEmpty

    disposable.dispose()
}

example(of: "combineLatest") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()

    //always combine the latest element in left and right
//    let observable = Observable.combineLatest(left, right) {
//        ($0, $1)
//        }.filter { !$0.0.isEmpty }

    let observable = Observable.combineLatest([left, right]) {
        strings in
        strings.joined(separator: " ")
    }

    let disposable = observable.subscribe(onNext: {
        print($0)
    })

    print("> Sending a value to Left")
    left.onNext("Hello, ")
    print("> Sending a value to Right")
    right.onNext("world")
    print("> Sending another value to Right")
    right.onNext("RxSwift")
    print("> Sending another value to Left")
    left.onNext("Have a good day")

    disposable.dispose()
}

example(of: "combine user choice and value") {
    let choice : Observable<DateFormatter.Style> = Observable.of(.short, .long)
    let dates = Observable.of(Date())

    let observable = Observable.combineLatest(choice, dates) {
        (format, when) -> String in
        let formatter = DateFormatter()
        formatter.dateStyle = format
        return formatter.string(from: when)
    }

    observable.subscribe(onNext: { print($0) })
}

example(of: "zip") {
    enum Weather {
        case cloudy
        case sunny
    }

    let left: Observable<Weather> = Observable.of(.sunny, .cloudy, .cloudy, .sunny)
    let right = Observable.of("Lisbon", "Copenhagen", "London", "Madrid", "Vienna")

    //zip called and closure with both new values
    let observable = Observable.zip(left, right) {
        weather, city in
        return "It's \(weather) in \(city)"
    }

    observable.subscribe(onNext: { print($0) })
}

example(of: "withLatestFrom") {
    let button = PublishSubject<Void>()
    let textField = PublishSubject<String>()

    //"withLatestFrom" when button emits a value,ignore it and emit the latest value received from the simulated text field
    //if want to get the current (latest) value use "withLatestFrom"
//    let observable = button.withLatestFrom(textField)

    //"sample" emits the latest value, if after that no new data arrived, sample will not emit anything
    //this behavior is as same as "withLatestFrom().distinctUntilChanged()"
//    let observable = textField.sample(button)

    let observable = button.withLatestFrom(textField).distinctUntilChanged()
    _ = observable.subscribe(onNext: { print($0) })

    textField.onNext("Par")
    textField.onNext("Pari")
    button.onNext(())

    textField.onNext("Paris")
    button.onNext(())
    button.onNext(())
}

example(of: "amb") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()

    //amb -> "ambiguous"
    //amb subscribes left and right, wait any of them emit an element and unsubscribe from the other one
    //after that, only relays elements from the first active observable
    let observable = left.amb(right)
    let disposable = observable.subscribe(onNext: { print($0) })

    left.onNext("Lisbon")
    right.onNext("Copenhagen")
    left.onNext("London")
    left.onNext("Madrid")
    right.onNext("Vienna")

    disposable.dispose()
}

example(of: "switchLatest") {
    let one = PublishSubject<String>()
    let two = PublishSubject<String>()
    let three = PublishSubject<String>()

    let source = PublishSubject<Observable<String>>()

    //subscription only prints items from the latest sequence pushed to the source observable
    let observable = source.switchLatest()
    let disposable = observable.subscribe(onNext: { print($0) })

    source.onNext(one)
    one.onNext("Some text from sequence one")
    two.onNext("Some text from sequence two")
    one.onNext("and also from sequence one")

    source.onNext(two)
    two.onNext("More text from sequence two")

    source.onNext(three)
    two.onNext("Still sequence two")
    one.onNext("sequence one")
    three.onNext("Finaly sequence three")

    source.onNext(one)
    one.onNext("sequence one is coming")
}

example(of: "reduce") {
    let source = Observable.of(1, 3, 5, 7, 9)

    //use + to accumulate values
//    let observable = source.reduce(0, accumulator: +)

    //start from 0, each time emit an item, call the closure to produce a new summary
    let observable = source.reduce(0, accumulator: { summary, newValue in
        return summary + newValue
    })
    observable.subscribe(onNext: { print($0) })
}

example(of: "scan") {
    let source = Observable.of(1, 3, 5, 7, 9)

    //scan: each time emit an element, pass the running value with the new element, and return the new accumulated value

    //combine two values, method 1, ---- using zip
//    let observable = source.scan(0, accumulator: +)
//    let sourceZip = Observable.zip(source, observable) {
//        source, observable in
//        return "Current: \(source). Total: \(observable)"
//    }
//
//    sourceZip.subscribe(onNext: { print($0) })

    //combine two values, method 2, ---- using scan
    let observable = source.scan((0, 0), accumulator: { total, current in
        return (current, total.1 + current)
    })
    observable.subscribe(onNext: {
        print("Current: \($0.0). Total: \($0.1)")
    })
    
}
