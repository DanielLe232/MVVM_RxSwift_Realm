import UIKit
import RxSwift
import RxCocoa

final class ListViewModel {
    
    private let databaseService: DatabaseService
    private var disposeBag = DisposeBag()
    
    let searchText = PublishSubject<String>()
    let cancelButton = PublishSubject<Void>()
    let selectedIndexSubject = PublishSubject<IndexPath>()
    
    let list = PublishSubject<[Group]>()
    var selectedGroup = PublishSubject<Group>()
    
    init(databaseService: DatabaseService) {
        self.databaseService = databaseService
        
//        self.databaseService.fetchGroup()
//            .map { $0 }
//            .bind(to: self.list)
//            .disposed(by: disposeBag)
        
        self.databaseService.fetchGroup()
            .map { $0 }
            .subscribe { (gr) in
                self.list.on(gr)
                self.list.onCompleted()
            }.disposed(by: disposeBag)
        
        // select row
        self.selectedIndexSubject
            .asObservable()
            .withLatestFrom(list){
                (indexPath, repo) in
                return repo[indexPath.item]
            }
            .map { $0 }
            .bind(to: self.selectedGroup)
            .disposed(by: disposeBag)
        
        // search
        self.searchText
            .asObservable()
            .filter { $0.count > 0}
            .throttle(0.2, scheduler: MainScheduler.instance)
            .flatMapLatest { gr in
                self.databaseService.searchGroup(gr.lowercased())
            }
            .bind(to: list)
            .disposed(by: disposeBag)
        
        // cancel search
        self.cancelButton
            .asObservable()
            .flatMapLatest {
                self.databaseService.fetchGroup()
            }
            .bind(to: list)
            .disposed(by: disposeBag)
    }
    
    func addGroup(_ name: String) {
        let gr = Group()
        gr.name = name
        databaseService.saveGroup(gr, withEdit: false)
    }
    
}
