//: Playground - noun: a place where people can play

import UIKit
import RxSwift
import RxCocoa
import Realm

/* “PublishSubject: Starts empty and only emits new elements to subscribers.”
 * “BehaviorSubject: Starts with an initial value and replays it or the latest element to new subscribers.”
 * “ReplaySubject: Initialized with a buffer size and will maintain a buffer of elements up to that size and replay it to new subscribers.”
 * “Variable: Wraps a BehaviorSubject, preserves its current value as state, and replays only the latest/initial value to new subscribers.”
 */

example(of: "PublishSubject") {
    let subject = PublishSubject<String>()

    subject.onNext("Is anyone listening?")

    let subscriptionOne = subject.subscribe(onNext: { string in
        print(string)
    })

    subject.on(.next("1"))
    subject.onNext("2")

    let subscriptionTwo = subject.subscribe{ event in
        print("2)", event.element ?? event)
    }

    //this print twice,
    subject.onNext("3")

    //stop one
    subscriptionOne.dispose()

    //only two running
    //if publish subject receive .completed or .error, also known as a stop event
    subject.onNext("4")

    //after completed, will not receive the element
    //new subscribe 3, start listening, but no value in it, and then disposed, so "?" will not print out
    subject.onCompleted()
    subject.onNext("5")
    subscriptionTwo.dispose()
    let disposeBag = DisposeBag()
    subject.subscribe{
        print("3)", $0.element ?? $0)
        }
        .disposed(by: disposeBag)

    subject.onNext("?")
}

enum MyEror: Error {
    case anError
}

func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
    print(label, event.element ?? event.error ?? event)
}

example(of: "BehaviorSubject") {
    let subject = BehaviorSubject(value: "Initial value")

    let disposeBag = DisposeBag()

    //subscription created after the subject. no element added to the subject, replays the initial one
    subject.subscribe {
        print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)

    //now X is the latest element
    subject.onNext("X")

    //compare Initial and X, onError is the most recent
    subject.onError(MyEror.anError)
    subject.subscribe {
        print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
}

example(of: "ReplaySubject") {
    let subject = ReplaySubject<String>.create(bufferSize: 2)

    let disposeBag = DisposeBag()

    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")

    //1 never get emitted, before anything subscribed to it, 2,3 is added
    subject.subscribe {
        print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)

    subject.subscribe {
        print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)

    subject.onNext("4")
    subject.onError(MyEror.anError)
    subject.dispose()
    subject.subscribe {
        print(label: "3)", event: $0)
        }
        .disposed(by: disposeBag)
}

example(of: "Variable") {
    let variable = Variable("Initial value")

    let disposeBag = DisposeBag()

    variable.value = "New initial value"

    variable.asObservable()
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)

    variable.value = "1"
    variable.asObservable()
        .subscribe {
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)

    variable.value = "2"
}

example(of: "PublishSubject") {

    let disposeBag = DisposeBag()

    let dealtHand = PublishSubject<[(String, Int)]>()

    func deal(_ cardCount: UInt) {
        var deck = cards
        var cardsRemaining: UInt32 = 52
        var hand = [(String, Int)]()

        for _ in 0..<cardCount {
            let randomIndex = Int(arc4random_uniform(cardsRemaining))
            hand.append(deck[randomIndex])
            deck.remove(at: randomIndex)
            cardsRemaining -= 1
        }

        // Add code to update dealtHand here
        if (points(for: hand) > 21) {
            dealtHand.onError(HandError.busted)
        } else {
            dealtHand.onNext(hand)
        }
    }

    // Add subscription to dealtHand here
    dealtHand.subscribe(
        onNext: {
            print(cardString(for: $0), "for", points(for: $0), "points")
    },
        onError: {
            print(String(describing: $0).capitalized)
    })
        .disposed(by: disposeBag)

    deal(3)
}

example(of: "Variable") {

    enum UserSession {

        case loggedIn, loggedOut
    }

    enum LoginError: Error {

        case invalidCredentials
    }

    let disposeBag = DisposeBag()

    // Create userSession Variable of type UserSession with initial value of .loggedOut
    let userSession = Variable(UserSession.loggedOut)

    // Subscribe to receive next events from userSession
    userSession.asObservable()
        .subscribe(onNext: {
            print("userSession changed: ", $0)
        })
        .disposed(by: disposeBag)

    func logInWith(username: String, password: String, completion: (Error?) -> Void) {
        guard username == "johnny@appleseed.com",
            password == "appleseed"
            else {
                completion(LoginError.invalidCredentials)
                return
        }

        // Update userSession
        userSession.value = .loggedIn
    }

    func logOut() {
        // Update userSession
        userSession.value = .loggedOut
    }

    func performActionRequiringLoggedInUser(_ action: () -> Void) {
        // Ensure that userSession is loggedIn and then execute action()
//        if userSession.value == .loggedIn {
//            action()
//        }

        guard userSession.value == .loggedIn else {
            print("You are logged out")
            return
        }
        action()
    }

    for i in 1...2 {
        let password = i % 2 == 0 ? "appleseed" : "password"

        logInWith(username: "johnny@appleseed.com", password: password) { error in
            guard error == nil else {
                print(error!)
                return
            }

            print("User logged in.")
        }

        performActionRequiringLoggedInUser {
            print("Successfully did something only a logged in user can do.")
        }
    }
}

example(of: "BehaviowRelay") {
    let behaviorRelay = BehaviorRelay(value: "1")
    behaviorRelay.asDriver()
        .debug("Debug----BehaviorRelay")
        .drive(onNext: { value in
            print(value)
        })
    behaviorRelay.accept("2")
}
