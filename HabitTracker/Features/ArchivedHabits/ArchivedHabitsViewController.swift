//
//  ArchivedHabitsViewController.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 24.06.2026.
//
import UIKit
import SnapKit
import Combine

final class ArchivedHabitsViewController: UIViewController {
    //MARK: - Properties
    private let viewModel: ArchivedHabitsViewModel
    private var habits: [ArchivedHabitModel] = []
    private var cancellables = Set<AnyCancellable>()
    
    private let titleLabel = UILabel()
    private let cancelButton = UIButton(type: .system)
    private let deleteAllButton = UIButton(type: .system)
    private let tableView = UITableView()
    private let emptyStateLabel = UILabel()
    
    
    //MARK: - Init
    init(viewModel: ArchivedHabitsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTableView()
        setupEmptyState()
        setupConstraints()
        bindViewModel()
        
        viewModel.loadArchivedHabits()
        
    }
}

    // MARK: - Setup
    private extension ArchivedHabitsViewController {
        func setupView() {
            view.backgroundColor = .systemBackground
            
            titleLabel.text = "Archive"
            titleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 16)
            titleLabel.textColor = .label
            
            cancelButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            cancelButton.tintColor = .label
            cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)

            deleteAllButton.setImage(UIImage(systemName: "trash"), for: .normal)
            deleteAllButton.tintColor = .systemRed
            deleteAllButton.addTarget(self, action: #selector(didTapDeleteAll), for: .touchUpInside)
            
            view.addSubview(titleLabel)
            view.addSubview(cancelButton)
            view.addSubview(deleteAllButton)
            
        }
        
        func setupTableView() {
            tableView.dataSource = self
            tableView.delegate = self

            tableView.register(
                ArchivedHabitCell.self,
                forCellReuseIdentifier: ArchivedHabitCell.reuseIdentifier
            )
            
            tableView.separatorStyle = .none
            tableView.backgroundColor = .clear
            tableView.showsVerticalScrollIndicator = false
            view.addSubview(tableView)
        }
        
        func setupEmptyState() {
            emptyStateLabel.text = "No archived habits yet."
            emptyStateLabel.font = UIFont(name: "Montserrat-Regular", size: 16)
            emptyStateLabel.textColor = .secondaryLabel
            emptyStateLabel.textAlignment = .center
            emptyStateLabel.isHidden = true
            
            view.addSubview(emptyStateLabel)
        }
        func setupConstraints() {
            cancelButton.snp.makeConstraints { make in
                make.leading.equalToSuperview().inset(20)
                make.centerY.equalTo(titleLabel)
                make.size.equalTo(36)
            }

            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
                make.centerX.equalToSuperview()
            }

            deleteAllButton.snp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(20)
                make.centerY.equalTo(titleLabel)
                make.size.equalTo(36)
            }
            
            tableView.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(20)
                make.leading.trailing.equalToSuperview().inset(20)
                make.bottom.equalToSuperview()
            }
            
            emptyStateLabel.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview().inset(20)
                    make.centerY.equalToSuperview()
                }
        }
    }

    // MARK: - Binding
    private extension ArchivedHabitsViewController {
        func bindViewModel() {
            viewModel.$habits
                .receive(on: DispatchQueue.main)
                .sink { [weak self] habits in
                    self?.renderHabits(habits)
                }
                .store(in: &cancellables)
                
        }
        
        func renderHabits(_ habits: [ArchivedHabitModel]) {
            self.habits = habits
            tableView.reloadData()
            
            let isEmpty = habits.isEmpty
            tableView.isHidden = isEmpty
            emptyStateLabel.isHidden = !isEmpty
            deleteAllButton.isHidden = habits.isEmpty
        }
    }

    //MARK: - Actions
    private extension ArchivedHabitsViewController {
        @objc private func didTapCancel() {
            dismiss(animated: true)
        }

        @objc private func didTapDeleteAll() {
            let alert = UIAlertController(
                title: "Delete all archived habits?",
                message: "This action cannot be undone.",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                self?.viewModel.permanentlyDeleteAllArchivedHabits()
            })

            present(alert, animated: true)
        }
        
        func confirmPermanentDelete(
            habit: ArchivedHabitModel,
            completion: @escaping (Bool) -> Void
        ) {
            let alert = UIAlertController(
                title: "Delete forever?",
                message: "This will permanently delete \"\(habit.title)\" and its progress history.",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completion(false)
            })

            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                self?.viewModel.permanentlyDeleteHabit(for: habit.id)
                completion(true)
            })

            present(alert, animated: true)
        }
    }


    // MARK: - UITableViewDataSource
extension ArchivedHabitsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        habits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ArchivedHabitCell.reuseIdentifier,
            for: indexPath
        ) as? ArchivedHabitCell else {
            return UITableViewCell()
        }
                         
        let habit = habits[indexPath.row]
        cell.configure(with: habit)
        
        cell.onRestoreTapped = { [weak self] in
            self?.viewModel.restoreHabit(for: habit.id)
        }
        
        return cell
    }
}

    // MARK: - UITableViewDelegate
    extension ArchivedHabitsViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            82
        }
        
        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let habit = habits[indexPath.row]
            
            let deleteAction = UIContextualAction(
                style: .destructive,
                title: "Delete"
            ) { [weak self] _, _, completion in
                self?.confirmPermanentDelete(habit: habit, completion: completion)
            }
            
            deleteAction.image = UIImage(systemName: "trash")
            
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }
    }

