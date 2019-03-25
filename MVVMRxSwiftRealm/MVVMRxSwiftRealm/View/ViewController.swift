import UIKit
import RxCocoa
import RxSwift
import EasyPeasy

class ViewController: UIViewController {
    private let viewModel: ListViewModel
    private let disposeBag = DisposeBag()
    
    private let mTableview: UITableView = {
        let tbl = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tbl.showsVerticalScrollIndicator = false
        tbl.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tbl
    }()
    
    let searchBarController = UISearchController(searchResultsController: nil)
    let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    
    init(viewModel: ListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBinding()
    }
    
    private func setupUI() {
        navigationItem.rightBarButtonItem = rightBarButton
        
        self.view.addSubview(mTableview)
        mTableview.easy.layout(
            Edges()
        )
        
        searchBarController.searchResultsUpdater = nil
        searchBarController.hidesNavigationBarDuringPresentation = false
        searchBarController.dimsBackgroundDuringPresentation = false
        searchBarController.searchBar.placeholder = "Search"
        mTableview.tableHeaderView = searchBarController.searchBar
        
    }
    
    private func setupBinding() {
                        
        rightBarButton.rx
            .tap
            .subscribe { _ in
                let addTodoAlert = UIAlertController(title: "Add Group", message: "Enter your string", preferredStyle: .alert)
                
                addTodoAlert.addTextField(configurationHandler: nil)
                addTodoAlert.addAction(UIAlertAction(title: "Add", style: .default, handler: { al in
                    let todoString = addTodoAlert.textFields![0].text
                    if !(todoString!.isEmpty) {
                        self.viewModel.addGroup(todoString!)
                    }
                }))
                
                addTodoAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                
                self.present(addTodoAlert, animated: true, completion: nil)

            }
            .disposed(by: disposeBag)
        
        searchBarController.searchBar.rx
            .text
            .orEmpty
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
        
        searchBarController.searchBar.rx
            .cancelButtonClicked
            .bind(to: viewModel.cancelButton)
            .disposed(by: disposeBag)
        
        viewModel.list
            .asObservable()
            .bind(to: mTableview.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) {
                (row, element, cell) in
                print("cooooo \(element.name)")
                cell.textLabel?.text = element.name
            }
            .disposed(by: disposeBag)
        
        mTableview.rx.itemSelected
            .asObservable()
            .bind(to: viewModel.selectedIndexSubject)
            .disposed(by: disposeBag)
        
        viewModel.selectedGroup
            .subscribe { [weak self] repoId in
                guard let strongSelf = self else { return }
                let alertController = UIAlertController(title: "\(repoId.element?.name ?? "")", message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                strongSelf.present(alertController, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        
    }
    
    
}

