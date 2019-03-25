import UIKit
import RxSwift
import RxCocoa
import RealmSwift

protocol DatabaseService {
    func searchGroup(_ text: String) -> Observable<[Group]>
    func saveGroup(_ group: Group, withEdit edit: Bool)
    func fetchGroup() -> Observable<[Group]>
    func deleteGroup(_ group: Group)
}

final class DatabaseManager: DatabaseService {
    
    private var listFromDB = PublishSubject<[Group]>()
    
    init() {
        listFromDB.onNext([Group()])
    }
    
    private func getListGroup() -> [Group] {
        let realm = try! Realm()
        let list = realm.objects(Group.self).sorted(byKeyPath: "name")
        print("first \(list.count)")
        return list.toArray(ofType: Group.self)
    }
    
    func saveGroup(_ group: Group, withEdit edit: Bool) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(group, update: edit)
            listFromDB.onNext(getListGroup())
        }
    }
    
    func fetchGroup() -> Observable<[Group]> {
        listFromDB.onNext(getListGroup())
        return listFromDB.asObservable()
    }
    
    func deleteGroup(_ group: Group) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(group)
            listFromDB.onNext(getListGroup())
        }
    }
    
    func searchGroup(_ text: String) -> Observable<[Group]> {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "name CONTAINS %@",text)
        let list = realm.objects(Group.self).filter(predicate)
        listFromDB.onNext(list.toArray(ofType: Group.self))
        return listFromDB.asObservable()
    }
    

}
