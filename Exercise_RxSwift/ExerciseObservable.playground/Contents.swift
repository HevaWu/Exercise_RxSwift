//: Playground - noun: a place where people can play

import UIKit
import RxSwift

example(of: "Obeservable") {
    let one = 1
    let two = 2
    let three = 3

    let observable: Observable<Int> = Observable<Int>.just(one)

    let observable2 = Observable.of(one, two, three)

    let observable3 = Observable.of([one, two, three])

    let observable4 = Observable.from([one, two, three])

    let observer = NotificationCenter.default.addObserver(
        forName: .UIKeyboardDidChangeFrame,
        object: nil,
        queue: nil) { notification in
            //handle receiving notification
    }

    let sequence = 0..<3

    var iterator = sequence.makeIterator()

    while let n = iterator.next() {
        print(n)
    }
}

example(of: "subscribe") {
    let one = 1
    let two = 2
    let three = 3

    let observable = Observable.of(one, two, three)

    observable.subscribe{ event in
        print(event)
    }

    observable.subscribe{ event in
        if let element = event.element {
            print(element)
        }
    }

    observable.subscribe(onNext: { element in
        print(element)
    })
}

example(of: "empty") {
    let observable = Observable<Void>.empty()

    observable.subscribe(
        onNext: { element in
            print(element)
    },
        onCompleted: {
            print("Completed")
    })
}

example(of: "range") {
    let observable = Observable<Int>.range(start: 1, count: 10)

    observable.subscribe(onNext: { i in
        let n = Double(i)
        let fibonacci = Int(((pow(1.61803, n) - pow(0.61803, n))/2.23606).rounded())
        print(fibonacci)
    })
}

example(of: "dispose") {
    let observable = Observable.of("A", "B", "C")

    let subscription = observable.subscribe{ event in
        print(event)
    }

    //explicitly cancel a subscription, the observable in the current example will stop emitting events
    subscription.dispose()
}

example(of: "DisposeBag") {
    let disposeBag = DisposeBag()

    Observable.of("A", "B", "C")
        .subscribe {
            print($0)
        }
        .disposed(by: disposeBag)
}

example(of: "create") {
    let disposeBag = DisposeBag()

    enum MyError: Error {
        case anError
    }

    Observable<String>.create{ observer -> Disposable in
        observer.onNext("1")

        //        observer.onError(MyError.anError)

        //        observer.onCompleted()

        observer.onNext("?")

        return Disposables.create()
        }
        .subscribe(
            onNext: {print($0)},
            onError: {print($0)},
            onCompleted: {print("Completed")},
            onDisposed: {print("Disposed")})
    //    .disposed(by: disposeBag)
}

example(of: "deferred") {
    let disposeBag = DisposeBag()

    var flip = false

    let factory: Observable<Int> = Observable.deferred{
        flip = !flip

        if flip {
            return Observable.of(1, 2, 3)
        } else {
            return Observable.of(4, 5, 6)
        }
    }

    for _ in 0...3 {
        factory.subscribe(onNext: {
            print($0, terminator: "")
        })
            .disposed(by: disposeBag)

        print()
    }
}

example(of: "Single") {
    let disposeBag = DisposeBag()

    enum FileReadError: Error {
        case fileNotFound, unreadable, encodingFailed
    }

    func loadText(from name: String) -> Single<String> {
        return Single.create { single in
            //create function must return disposable
            let disposable = Disposables.create()

            guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
                single(.error(FileReadError.fileNotFound))
                return disposable
            }

            guard let data = FileManager.default.contents(atPath: path) else {
                single(.error(FileReadError.unreadable))
                return disposable
            }

            guard let contents = String(data: data, encoding: .utf8) else {
                single(.error(FileReadError.encodingFailed))
                return disposable
            }

            single(.success(contents))
            return disposable
        }
    }

    loadText(from: "Copyright")
        .subscribe {
            switch $0 {
            case .success(let string):
                print(string)
            case .error(let error):
                print(error)
            }
        }
        .disposed(by: disposeBag)
}

example(of: "never") {
    let disposeBag = DisposeBag()

    let observable = Observable<Any>.never()

    observable.do(
        onSubscribe: {print("On Subscribe")})
        .subscribe(
            onNext: { element in
                print(element)
        },
            onCompleted: {print("Completed")},
            onDisposed: {print("Disposed")})
        .disposed(by: disposeBag)
}

example(of: "debug") {
    let disposeBag = DisposeBag()

    let observable = Observable<Any>.never()

    observable.debug("DebugIdentifier")
        .subscribe(
            onNext: { element in
                print(element)
        },
            onCompleted: {print("Completed")},
            onDisposed: {print("Disposed")})
        .disposed(by: disposeBag)
}

example(of: "Observable_Dispose_Error") {
    let disposeBag = DisposeBag()
    
    let publish = PublishSubject<Int>()
    let publish1 = PublishSubject<Int>()

    
    enum ObservableError: Error {
        case error
    }
    
    publish1
        .debug("Publish1")
        .flatMap {_ in
            publish
                .debug("Publish")
                .catchErrorJustReturn(3)
        }
//        .catchErrorJustReturn(13)
        .subscribe(onNext: { element in
            print(element)
        }, onError: { element in
            print(element)
        }, onCompleted: {
            print("Completed")
        }, onDisposed: {
            print("Disposed")
        })
        .disposed(by: disposeBag)
    
    publish1.onNext(11)
    
    publish.onNext(1)
    publish.onError(ObservableError.error)
    publish.onCompleted()
    publish.onNext(2)
    
    publish1.onNext(12)
}

