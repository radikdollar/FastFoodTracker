import UIKit

class EatTimeViewController: UIViewController {

    //MARK: - UI
    
    private let tableView = UITableView()
    
    private lazy var label: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.text = "My Fast Food Calencdar"
        $0.font = .systemFont(ofSize: 30, weight: .bold)
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    //MARK: - Outlets
    
    private var eatTimes: [EatTime] = []
    private var shouldHighlightNewCell = false
    private var pendingHighlightIndexPath: IndexPath?


    //MARK: - Lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Fast Food Calendar"
        
        setupUI()
        configureNavbar()

        eatTimes = CoreDataManager.shared.fetchEatTimes()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewEatTime(notification:)), name: .newEatTimeAdded, object: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            eatTimes = CoreDataManager.shared.fetchEatTimes()
            tableView.reloadData()
        }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: - Funcs and Methods
    
    func setupUI() {
        setupTable()
        view.addSubview(tableView)

        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                ])
    }
    
    func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        setupTableHeader()
    }
    
    private func setupTableHeader() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        headerView.backgroundColor = .systemGray6
        
        let dateLabel = UILabel()
        dateLabel.text = "Date"
        dateLabel.font = .boldSystemFont(ofSize: 20)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let timeLabel = UILabel()
        timeLabel.text = "Time"
        timeLabel.font = .boldSystemFont(ofSize: 20)
        timeLabel.textAlignment = .right
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(dateLabel)
        headerView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            dateLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            timeLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            timeLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            timeLabel.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    private func configureNavbar() {
        let menu = UIMenu(title: "", children: [
            UIAction(title: "Add meal time", image: UIImage(systemName: "plus"), handler: { [weak self] _ in
                self?.addManualEatTime()
            }),
            UIAction(title: "Delete last meal time", image: UIImage(systemName: "trash"), handler: { [weak self] _ in
                self?.deleteLastEatTime()
            }),
            UIAction(title: "Clear all", image: UIImage(systemName: "xmark.bin"), handler: { [weak self] _ in
                self?.confirmClearAll()
            })
        ])
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "ellipsis.circle"), primaryAction: nil, menu: menu)
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 20, weight: .bold)]
    }


    private func addManualEatTime() {
        let newEatTime = EatTime(context: CoreDataManager.shared.context)
        newEatTime.date = Date()
        do {
            try CoreDataManager.shared.context.save()
            eatTimes.insert(newEatTime, at: 0)
            tableView.reloadData()
        } catch {
            print("Failed to add eat time: \(error)")
        }
    }

    private func deleteLastEatTime() {
        guard !eatTimes.isEmpty else { return }
        let eatTimeToDelete = eatTimes.removeFirst()
        CoreDataManager.shared.context.delete(eatTimeToDelete)
        do {
            try CoreDataManager.shared.context.save()
            tableView.reloadData()
        } catch {
            print("Failed to delete last eat time: \(error)")
        }
    }

    private func clearAllEatTimes() {
        for eatTime in eatTimes {
            CoreDataManager.shared.context.delete(eatTime)
        }
        eatTimes.removeAll()
        do {
            try CoreDataManager.shared.context.save()
            tableView.reloadData()
        } catch {
            print("Failed to clear eat times: \(error)")
        }
    }
    
    private func confirmClearAll() {
        let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete all records?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete All", style: .destructive, handler: { [weak self] _ in
            self?.clearAllEatTimes()
        }))
        present(alert, animated: true, completion: nil)
    }

    //MARK: - Action
    @objc private func handleNewEatTime(notification: Notification) {
            guard let newEatTime = notification.object as? EatTime else { return }
            shouldHighlightNewCell = true

            eatTimes.insert(newEatTime, at: 0)

            tableView.beginUpdates()
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            tableView.endUpdates()
        }

}

//MARK: - Extensions

extension EatTimeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eatTimes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Создаём ячейку с style .value1 (чтобы был текст слева и справа)
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let eatTime = eatTimes[indexPath.row]
        
        if let date = eatTime.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"
            
            cell.textLabel?.text = dateFormatter.string(from: date)
            cell.detailTextLabel?.text = timeFormatter.string(from: date)
            
            cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 18)
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let eatTimeToDelete = eatTimes[indexPath.row]
            CoreDataManager.shared.context.delete(eatTimeToDelete)
            do {
                try CoreDataManager.shared.context.save()
                eatTimes.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                print("Failed to delete: \(error)")
            }
        }
    }
}
