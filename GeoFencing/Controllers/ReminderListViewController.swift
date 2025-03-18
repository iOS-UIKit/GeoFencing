//
//  ReminderListViewController.swift
//  GeoFencing
//
//  Created by Sameed Ansari on 18/03/2025.
//

import UIKit

protocol ReminderListViewControllerDelegate: AnyObject {
    func didSelectReminder(_ reminder: GeoFenceReminder)
}

class ReminderListViewController: UIViewController {
    
    weak var delegate: ReminderListViewControllerDelegate?
    
    private let remindersViewModel: RemindersViewModel
    private let tableView = UITableView()
    private let emptyStateLabel = UILabel()
    
    init(remindersViewModel: RemindersViewModel) {
        self.remindersViewModel = remindersViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupBindings()
        
        title = "Saved Reminders"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        remindersViewModel.loadReminders()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ReminderCell")
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        
        emptyStateLabel.text = "No reminders saved yet"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.font = UIFont.systemFont(ofSize: 16)
        emptyStateLabel.isHidden = true
        view.addSubview(emptyStateLabel)
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupBindings() {
        remindersViewModel.onRemindersUpdated = { [weak self] in
            guard let self = self else { return }
            self.updateUI()
        }
        
        remindersViewModel.onError = { [weak self] errorMessage in
            guard let self = self else { return }
            self.showAlert(with: "Error", message: errorMessage)
        }
    }
    
    private func updateUI() {
        tableView.reloadData()
        
        // Show/hide empty state
        let isEmpty = remindersViewModel.numberOfReminders() == 0
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    private func showAlert(with title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ReminderListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return remindersViewModel.numberOfReminders()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath)
        
        if let reminder = remindersViewModel.getReminder(at: indexPath.row) {
            var content = cell.defaultContentConfiguration()
            content.text = reminder.name
            content.secondaryText = "\(reminder.category) - \(Int(reminder.radius))m radius"
            
            if !reminder.note.isEmpty {
                content.secondaryText = content.secondaryText! + " - Note: \(reminder.note)"
            }
            
            cell.accessoryType = reminder.isActive ? .checkmark : .none
            
            cell.contentConfiguration = content
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let reminder = remindersViewModel.getReminder(at: indexPath.row) {
            delegate?.didSelectReminder(reminder)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let reminder = remindersViewModel.getReminder(at: indexPath.row) else {
            return nil
        }
        
        let toggleTitle = reminder.isActive ? "Disable" : "Enable"
        let toggleAction = UIContextualAction(style: .normal, title: toggleTitle) { [weak self] (_, _, completion) in
            guard let self = self else { return }
            
            let _ = self.remindersViewModel.toggleReminder(with: reminder.id, isActive: !reminder.isActive)
            completion(true)
        }
        toggleAction.backgroundColor = reminder.isActive ? .systemOrange : .systemGreen
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            
            let _ = self.remindersViewModel.deleteReminder(with: reminder.id)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction, toggleAction])
    }
} 
