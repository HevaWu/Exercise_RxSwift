import UIKit
import RxSwift
import PlaygroundSupport

class TestVC: UIViewController {
    let fruiteList = ["apple", "orange", "banana"]
    let task1 = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        task1.asObserver()
            .flatMap { [weak self] str -> Observable<Void> in
                print(self?.fruiteList)
                return .empty()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    deinit {
        print("Deinit ViewController")
    }
}

let testVC = TestVC()
PlaygroundPage.current.liveView = testVC
PlaygroundPage.current.needsIndefiniteExecution = true
