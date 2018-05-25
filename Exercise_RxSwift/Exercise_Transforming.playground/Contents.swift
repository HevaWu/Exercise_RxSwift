//: Playground - noun: a place where people can play

import UIKit
import RxSwift
import RxSwiftExt


example(of: "toArray") {
    let disposeBag = DisposeBag()

    Observable.of("A", "B", "C")
        .toArray()
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "map") {
    let disposeBag = DisposeBag()

    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut

    Observable<NSNumber>.of(123, 4, 56)
        .map{
            formatter.string(from: $0) ?? ""
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "enumerated and map") {
    let disposeBag = DisposeBag()

    //enumerated produce pairs of each element and its index
    Observable.of(1, 2, 3, 4, 5, 6)
        .enumerated()
        .map{ index, integer in
            index > 2 ? integer * 2 : integer
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

struct Student {
    var score: BehaviorSubject<Int>
}
<<<<<<< Updated upstream

example(of: "flatMap") {
    let disposeBag = DisposeBag()

    let ryan = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 90))

    let student = PublishSubject<Student>()

    //flatmap keep up with each and every observable it creates, all element is been monitored
    student.flatMap{
        $0.score
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)

    student.onNext(ryan)
    ryan.score.onNext(85)
    student.onNext(charlotte)
    ryan.score.onNext(95)
    charlotte.score.onNext(100)
}

example(of: "flatMapLatest") {
    let disposeBag = DisposeBag()

    let ryan = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 90))

    let student = PublishSubject<Student>()

    //flatmap keep up with each and every observable it creates, all element is been monitored
    student.flatMapLatest{
        $0.score
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)

    student.onNext(ryan)
    ryan.score.onNext(85)
    student.onNext(charlotte)

    //this one is ignored, because ryan is not the latest one been monitored
    ryan.score.onNext(95)
    charlotte.score.onNext(100)

    //if we want to ignore the result of previous one, flatMapLatest is suggested
}

example(of: "materialize and dematerialize") {
    enum MyError: Error {
        case anError
    }

    let disposeBag = DisposeBag()

    let ryan = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 100))

    let student = BehaviorSubject(value: ryan)

    //    let studentScore = student.flatMapLatest {
    //        $0.score
    //    }
    //
    //    studentScore.subscribe(onNext: {
    //        print($0)
    //    })
    //        .disposed(by: disposeBag)
    //
    //    ryan.score.onNext(85)
    //    ryan.score.onError(MyError.anError)

    //error is unhandled, the studentScore observable terminates, also for student observable
    //    ryan.score.onNext(90)
    //    student.onNext(charlotte)

    //-------------materialize--------------
    //    let studentScore = student.flatMapLatest {
    //        $0.score.materialize()
    //    }
    //
    //    studentScore.subscribe(onNext: {
    //        print($0)
    //    })
    //        .disposed(by: disposeBag)
    //
    //    ryan.score.onNext(85)
    //    ryan.score.onError(MyError.anError)
    //
    //    //materialize
    //    //error still causes the studentScore terminate, but not the outer student observable
    //    ryan.score.onNext(90)
    //    student.onNext(charlotte)

    //-------------dematerialize--------------
    let studentScore = student.flatMapLatest {
        $0.score.materialize()
    }

    //dematerialize
    //student observable is protected by errors on its inner score observable
    //error is printed and ryan's studentScore is terminated, add new score onto him does nothing
    //add charlotte will be printed
    studentScore
        .filter {
            guard $0.error == nil else {
                print($0.error)
                return false
            }
            return true
        }
        .dematerialize()
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)

    ryan.score.onNext(85)
    ryan.score.onError(MyError.anError)
    ryan.score.onNext(90)
    student.onNext(charlotte)
}

example(of: "Challenge 1") {
    let disposeBag = DisposeBag()

    let contacts = [
        "603-555-1212": "Florent",
        "212-555-1212": "Junior",
        "408-555-1212": "Marin",
        "617-555-1212": "Scott"
    ]

    let convert: (String) -> UInt? = { value in
        if let number = UInt(value),
            number < 10 {
            return number
        }

        let keyMap: [String: UInt] = [
            "abc": 2, "def": 3, "ghi": 4,
            "jkl": 5, "mno": 6, "pqrs": 7,
            "tuv": 8, "wxyz": 9
        ]

        let converted = keyMap
            .filter { $0.key.contains(value.lowercased()) }
            .map { $0.value }
            .first

        return converted
    }

    let format: ([UInt]) -> String = {
        var phone = $0.map(String.init).joined()

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

    let dial: (String) -> String = {
        if let contact = contacts[$0] {
            return "Dialing \(contact) (\($0))..."
        } else {
            return "Contact not found"
        }
    }

    let input = Variable<String>("")

    // Add your code here
    // use unwrap to retrieve the elements after convert
    input.asObservable()
        .map(convert)
        .unwrap()
        .skipWhile{
            $0 == 0
        }
        .take(10)
        .toArray()
        .map(format)
        .map(dial)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)


    input.value = ""
    input.value = "0"
    input.value = "408"

    input.value = "6"
    input.value = ""
    input.value = "0"
    input.value = "3"

    "JKL1A1B".forEach {
        input.value = "\($0)"
    }

    input.value = "9"
}
=======
>>>>>>> Stashed changes
