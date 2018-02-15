//: Playground - noun: a place where people can play

import UIKit
import RxSwift

example(of: "ignoreElements") {
    let strikes = PublishSubject<String>()

    let disposeBag = DisposeBag()

    //ignoreElements ignore .next event, allow .next .completed .error
    strikes
        .ignoreElements()
        .subscribe { _ in
            print("You are out")
        }
        .disposed(by: disposeBag)

    //ignore next
    strikes.onNext("X")

    //receive complete element
    strikes.onCompleted()
}

example(of: "elementAt") {
    let strikes = PublishSubject<String>()

    let disposeBag = DisposeBag()

    strikes.elementAt(2)
        .subscribe(onNext: { _ in
            print("You are out")
        })
        .disposed(by: disposeBag)

    strikes.onNext("X1")
    strikes.onNext("X2")

    //only this one call the subscription
    strikes.onNext("X3")
}

example(of: "filter") {
    let disposeBag = DisposeBag()

    //filter the element you want to subscription
    Observable.of(1, 2, 3, 4, 5, 6)
        .filter{ index in
            index % 2 == 0
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "skip") {
    let disposeBag = DisposeBag()

    //skip first 3 elements
    Observable.of("A", "B", "C", "D", "E", "F")
        .skip(3)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "skipWhile") {
    let disposeBag = DisposeBag()

    //skipWhile only skip up until some element is not skipped
    Observable.of(2, 2, 3, 4, 4)
        .skipWhile{ integer in
            integer % 2 == 0
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "skipUntil") {
    let disposeBag = DisposeBag()

    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()

    //when trigger emit, skipUtil will stop skippping
    subject
        .skipUntil(trigger)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)

    subject.onNext("A")
    subject.onNext("B")
    trigger.onNext("X")

    //this will show up, because trigger has emit
    subject.onNext("C")
}

example(of: "take") {
    let disposeBag = DisposeBag()

    //take the first 3 elements
    Observable.of(1, 2, 3, 4, 5, 6)
        .take(3)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "takeWhile") {
    let disposeBag = DisposeBag()

    //enumerated reference the index of the element
    //only take the first 3 elements, and choose the element %2==0
    Observable.of(2, 2, 4, 4, 6, 6)
        .enumerated()
        .takeWhile{ index, integer  in
            integer % 2 == 0 && index < 3
        }
        .map{ $0.element }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "takeUtil") {
    let disposeBag = DisposeBag()

    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()

    subject.takeUntil(trigger)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)

    //this two will show up
    subject.onNext("1")
    subject.onNext("2")

    //after trigger emit the element, subject will not subscription other element
    trigger.onNext("X")
    subject.onNext("3")
}

example(of: "distinctUntilChanged") {
    let disposeBag = DisposeBag()

    //distinctUntilChanged prevent duplicates from the former one
    Observable.of("A", "A", "B", "B", "A")
        .distinctUntilChanged()
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "distinctUntilChanged(_:)") {
    let disposeBag = DisposeBag()

    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut

    Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
        .distinctUntilChanged{ a, b in
            //check if two elements contains same components

            guard let aWords = formatter.string(from: a)?.components(separatedBy: " "),
                let bWords = formatter.string(from: b)?.components(separatedBy: " ") else {
                    return false
            }

            var containsMatch = false

            for aWord in aWords {
                for bWord in bWords {
                    if aWord == bWord {
                        containsMatch = true
                        break
                    }
                }
            }

            print(aWords, " ", bWords, " ", containsMatch)

            return containsMatch
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "Challenge 1") {

    let disposeBag = DisposeBag()

    let contacts = [
        "603-555-1212": "Florent",
        "212-555-1212": "Junior",
        "408-555-1212": "Marin",
        "617-555-1212": "Scott"
    ]

    func phoneNumber(from inputs: [Int]) -> String {
        var phone = inputs.map(String.init).joined()

        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 3)
        )

        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 7)
        )

        return phone
    }

    let input = PublishSubject<Int>()

    // Add your code here
    input.skipWhile{
        //phone nuber cannot begin with 0
            $0 == 0
        }
        .filter{
            //only allow single digit
            $0 < 10
        }
        .take(10)
        .toArray()
        .subscribe(onNext: {
            let phone = phoneNumber(from: $0)

            if let contact = contacts[phone] {
                print("Dialing \(contact) (\(phone))...")
            } else {
                print("Contact not found")
            }

        })
        .disposed(by: disposeBag)

    input.onNext(0)
    input.onNext(603)

    input.onNext(2)
    input.onNext(1)

    // Confirm that 7 results in "Contact not found", and then change to 2 and confirm that Junior is found
    input.onNext(7)

    "5551212".characters.forEach {
        if let number = (Int("\($0)")) {
            input.onNext(number)
        }
    }

    input.onNext(9)
}
