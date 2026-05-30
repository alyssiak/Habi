//
//  ViewController.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 30.04.2026.
//

import UIKit
import SnapKit

final class HabitTrackerViewController: UIViewController {

    private let avatarImageView = UIImageView()
    private let greetingLabel = UILabel()
    private let motivationLabel = UILabel()
    private let addHabitButton = UIButton()
    private let headerStackView = UIStackView()
    private let textStackView = UIStackView()
    private let habitsTableView = UITableView()
    private var habitModels: [HabitCardModel] = []
    private let viewModel: HabitTrackerViewModel

    private enum Layout {
        static let horizontalInset: CGFloat = 20
        static let headerTopOffset: CGFloat = 24
        static let tableTopOffset: CGFloat = 26
        static let avatarSize: CGFloat = 56
        static let addButtonSize: CGFloat = 56
        static let addButtonBottomOffset: CGFloat = 20
        static let tableBottomInset: CGFloat = 88
        static let rowHeight: CGFloat = 100
    }
    
    init(viewModel: HabitTrackerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupHeader()
        setupHabitsTableView()
        setupConstraints()
        bindViewModel()
        viewModel.loadHabits()
    }
  
    private func setupView() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupHeader() {
        avatarImageView.image = UIImage(systemName: "person.circle")
        avatarImageView.tintColor = .systemGray
        avatarImageView.contentMode = .scaleAspectFit
        
        greetingLabel.text = "Hello!"
        greetingLabel.font = UIFont(name: "Montserrat-SemiBold", size: 24)
        
        motivationLabel.text = "Track your habits to stay motivated."
        motivationLabel.textColor = .secondaryLabel
        motivationLabel.font =  UIFont(name: "Montserrat-Regular", size: 18)
        motivationLabel.numberOfLines = 0
        
        addHabitButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addHabitButton.backgroundColor = .systemOrange
        addHabitButton.tintColor = .white
        addHabitButton.layer.cornerRadius = 8
        addHabitButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        
        textStackView.axis = .vertical
        textStackView.spacing = 6
        textStackView.addArrangedSubview(greetingLabel)
        textStackView.addArrangedSubview(motivationLabel)
        
        headerStackView.axis = .horizontal
        headerStackView.spacing = 16
        headerStackView.alignment = .center
        headerStackView.addArrangedSubview(avatarImageView)
        headerStackView.addArrangedSubview(textStackView)
        view.addSubview(headerStackView)
        view.addSubview(addHabitButton)
    }
    
    private func setupHabitsTableView() {
        habitsTableView.dataSource = self
        habitsTableView.delegate = self
        
        habitsTableView.register(
            HabitCardCell.self,
            forCellReuseIdentifier: HabitCardCell.reuseIdentifier
        )
        
        habitsTableView.separatorStyle = .none
        habitsTableView.backgroundColor = .clear
        habitsTableView.showsVerticalScrollIndicator = false
        
        habitsTableView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: Layout.tableBottomInset,
            right: 0
        )
        
        view.addSubview(habitsTableView)
        view.bringSubviewToFront(addHabitButton)
    }
    
    // подписываем контроллер на обновления
    private func bindViewModel() {
        viewModel.onHabitsChanged = { [weak self] models in
            self?.renderHabits(models)
        }
    }
    
    private func renderHabits(_ models: [HabitCardModel]) {
        habitModels = models
        habitsTableView.reloadData()
    }
    
    private func confirmDeleteHabit(model: HabitCardModel, completion: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(
            title: "Delete habit?",
            message: "This will remove \"\(model.title)\" from your list.",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        })
        
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else {
                completion(false)
                return
            }
            
            viewModel.deleteHabit(for: model.id)
            completion(true)
        })
        
        present(alertController, animated: true)
    }
    
    private func setupConstraints() {
        
        avatarImageView.snp.makeConstraints { make in
            make.size.equalTo(Layout.avatarSize)
        }
        
        headerStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Layout.headerTopOffset)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }
        
        habitsTableView.snp.makeConstraints { make in
            make.top.equalTo(headerStackView.snp.bottom).offset(Layout.tableTopOffset)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.equalToSuperview()
        }
        
        addHabitButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(Layout.addButtonBottomOffset)
            make.size.equalTo(Layout.addButtonSize)
        }
    }
    
    @objc private func didTapAddButton() {
        let addHabitViewController = AddHabitViewController(viewModel: viewModel)
        addHabitViewController.onHabitAdded = { [weak self] in
            self?.viewModel.loadHabits()
        }
        present(addHabitViewController, animated: true)
    }
}

extension HabitTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habitModels.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Layout.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: HabitCardCell.reuseIdentifier,
            for: indexPath
        ) as? HabitCardCell else {
            return UITableViewCell()
        }
        
        let model = habitModels[indexPath.row]
        cell.configure(with: model)
        
        cell.onDoneTapped = { [weak self] in
            self?.viewModel.toggleToday(for: model.id)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let model = habitModels[indexPath.row]
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete") { [weak self] _, _, completion in
                guard let self else {
                    completion(false)
                    return
                }
                
                confirmDeleteHabit(model: model, completion: completion)
            }
            deleteAction.image = UIImage(systemName: "trash")
            
            return UISwipeActionsConfiguration(actions: [deleteAction])
    
        
    }
}
