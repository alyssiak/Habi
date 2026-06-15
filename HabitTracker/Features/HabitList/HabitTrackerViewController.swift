//
//  ViewController.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 30.04.2026.
//

import UIKit
import SnapKit
import CoreData

final class HabitTrackerViewController: UIViewController {

    // MARK: - UI

    private let avatarImageView = UIImageView()
    private let greetingLabel = UILabel()
    private let motivationLabel = UILabel()
    private let addHabitButton = UIButton()
    private let headerStackView = UIStackView()
    private let textStackView = UIStackView()
    private let habitsTableView = UITableView()
    private let emptyStateStackView = UIStackView()
    private let emptyTitleLabel = UILabel()
    private let emptySubtitleLabel = UILabel()
    private let undoBannerView = UIView()
    private let undoBannerStackView = UIStackView()
    private let undoMessageLabel = UILabel()
    private let undoButton = UIButton(type: .system)

    // MARK: - State

    private var habitModels: [HabitCardModel] = []
    private let viewModel: HabitTrackerViewModel
    private var archivedHabitStack: [ArchivedHabitUndoItem] = []
    private var hideUndoBannerWorkItem: DispatchWorkItem?

    // MARK: - Layout

    private enum Layout {
        static let horizontalInset: CGFloat = 20
        static let headerTopOffset: CGFloat = 24
        static let tableTopOffset: CGFloat = 26
        static let avatarSize: CGFloat = 56
        static let addButtonSize: CGFloat = 56
        static let addButtonBottomOffset: CGFloat = 20
        static let tableBottomInset: CGFloat = 88
        static let rowHeight: CGFloat = 88
        static let rowSpacing: CGFloat = 12
        static let undoBannerHeight: CGFloat = 52
        static let undoBannerBottomOffset: CGFloat = 12
        static let undoBannerHideDelay: TimeInterval = 10
    }

    private struct ArchivedHabitUndoItem {
        let id: NSManagedObjectID
        let title: String
    }

    // MARK: - Init

    init(viewModel: HabitTrackerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupHeader()
        setupHabitsTableView()
        setupEmptyState()
        setupUndoBanner()
        setupConstraints()
        bindViewModel()
        viewModel.loadHabits()
    }
}

// MARK: - Setup

private extension HabitTrackerViewController {

    func setupView() {
        view.backgroundColor = .systemBackground
    }

    func setupHeader() {
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

    func setupHabitsTableView() {
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

    func setupEmptyState() {
        emptyTitleLabel.text = "No habits yet"
        emptyTitleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 20)
        emptyTitleLabel.textColor = .label
        emptyTitleLabel.textAlignment = .center

        emptySubtitleLabel.text = "Tap + to add your first habit"
        emptySubtitleLabel.font = UIFont(name: "Montserrat-Regular", size: 15)
        emptySubtitleLabel.textColor = .secondaryLabel
        emptySubtitleLabel.textAlignment = .center
        emptySubtitleLabel.numberOfLines = 0

        emptyStateStackView.axis = .vertical
        emptyStateStackView.spacing = 8
        emptyStateStackView.alignment = .center
        emptyStateStackView.isHidden = true
        emptyStateStackView.addArrangedSubview(emptyTitleLabel)
        emptyStateStackView.addArrangedSubview(emptySubtitleLabel)

        view.addSubview(emptyStateStackView)
        view.bringSubviewToFront(addHabitButton)
    }

    func setupUndoBanner() {
        undoBannerView.backgroundColor = .label
        undoBannerView.layer.cornerRadius = 8
        undoBannerView.alpha = 0
        undoBannerView.isHidden = true

        undoMessageLabel.font = UIFont(name: "Montserrat-Medium", size: 14)
        undoMessageLabel.textColor = .systemBackground
        undoMessageLabel.numberOfLines = 1
        undoMessageLabel.lineBreakMode = .byTruncatingTail

        undoButton.setTitle("Undo", for: .normal)
        undoButton.setTitleColor(.systemOrange, for: .normal)
        undoButton.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 14)
        undoButton.addTarget(self, action: #selector(didTapUndoDelete), for: .touchUpInside)

        undoBannerStackView.axis = .horizontal
        undoBannerStackView.alignment = .center
        undoBannerStackView.spacing = 12
        undoBannerStackView.addArrangedSubview(undoMessageLabel)
        undoBannerStackView.addArrangedSubview(undoButton)

        undoButton.setContentHuggingPriority(.required, for: .horizontal)
        undoButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        undoMessageLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        undoBannerView.addSubview(undoBannerStackView)
        view.addSubview(undoBannerView)
        view.bringSubviewToFront(undoBannerView)
        view.bringSubviewToFront(addHabitButton)
    }

    func setupConstraints() {

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

        emptyStateStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.centerY.equalToSuperview().offset(40)
        }

        addHabitButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(Layout.addButtonBottomOffset)
            make.size.equalTo(Layout.addButtonSize)
        }

        undoBannerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.equalTo(addHabitButton.snp.top).offset(-Layout.undoBannerBottomOffset)
            make.height.equalTo(Layout.undoBannerHeight)
        }

        undoBannerStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
}

// MARK: - Binding

private extension HabitTrackerViewController {

    func bindViewModel() {
        viewModel.onHabitsChanged = { [weak self] models in
            self?.renderHabits(models)
        }
    }

    func renderHabits(_ models: [HabitCardModel]) {
        habitModels = models
        habitsTableView.reloadData()
        updateEmptyState()
    }

    func updateEmptyState() {
        let isEmpty = habitModels.isEmpty

        habitsTableView.isHidden = isEmpty
        emptyStateStackView.isHidden = !isEmpty
    }
}

// MARK: - Actions

private extension HabitTrackerViewController {

    @objc func didTapAddButton() {
        let addHabitViewController = AddHabitViewController(viewModel: viewModel)
        addHabitViewController.onHabitSaved = { [weak self] in
            self?.viewModel.loadHabits()
        }
        present(addHabitViewController, animated: true)
    }

    func openEditHabit(model: HabitCardModel) {
        let addHabitViewController = AddHabitViewController(
            viewModel: viewModel,
            mode: .edit(model)
        )

        addHabitViewController.onHabitSaved = { [weak self] in
            self?.viewModel.loadHabits()
        }

        present(addHabitViewController, animated: true)
    }

    func confirmDeleteHabit(
        model: HabitCardModel,
        completion: @escaping (Bool) -> Void = { _ in }
    ) {
        let alertController = UIAlertController(
            title: "Delete habit?",
            message: "This will remove \"\(model.title)\" from your list. You can undo it right after.",
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
            showUndoBanner(for: model)
            completion(true)
        })

        present(alertController, animated: true)
    }

    func showUndoBanner(for model: HabitCardModel) {
        archivedHabitStack.append(
            ArchivedHabitUndoItem(
                id: model.id,
                title: model.title
            )
        )

        updateUndoBannerText()
        showUndoBanner()
        scheduleUndoBannerHide()
    }

    func showUndoBanner() {
        undoBannerView.isHidden = false

        UIView.animate(withDuration: 0.2) {
            self.undoBannerView.alpha = 1
        }
    }

    func hideUndoBanner(clearStack: Bool) {
        if clearStack {
            archivedHabitStack.removeAll()
        }

        hideUndoBannerWorkItem?.cancel()

        UIView.animate(withDuration: 0.2) {
            self.undoBannerView.alpha = 0
        } completion: { [weak self] _ in
            self?.undoBannerView.isHidden = true
        }
    }

    func updateUndoBannerText() {
        if archivedHabitStack.count > 1 {
            undoMessageLabel.text = "\(archivedHabitStack.count) habits deleted"
        } else if let item = archivedHabitStack.last {
            undoMessageLabel.text = "\"\(item.title)\" deleted"
        }
    }

    func scheduleUndoBannerHide() {
        hideUndoBannerWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            self?.hideUndoBanner(clearStack: true)
        }

        hideUndoBannerWorkItem = workItem

        DispatchQueue.main.asyncAfter(
            deadline: .now() + Layout.undoBannerHideDelay,
            execute: workItem
        )
    }

    @objc func didTapUndoDelete() {
        guard let item = archivedHabitStack.popLast() else {
            hideUndoBanner(clearStack: false)
            return
        }

        viewModel.restoreHabit(for: item.id)

        if archivedHabitStack.isEmpty {
            hideUndoBanner(clearStack: false)
        } else {
            updateUndoBannerText()
            scheduleUndoBannerHide()
        }
    }
}

// MARK: - UITableViewDataSource

extension HabitTrackerViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return habitModels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: HabitCardCell.reuseIdentifier,
            for: indexPath
        ) as? HabitCardCell else {
            return UITableViewCell()
        }

        let model = habitModels[indexPath.section]
        cell.configure(with: model)

        cell.onDoneTapped = { [weak self] in
            self?.viewModel.toggleToday(for: model.id)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension HabitTrackerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Layout.rowHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return Layout.rowSpacing
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let model = habitModels[indexPath.section]

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }

            confirmDeleteHabit(model: model, completion: completion)
        }
        deleteAction.image = UIImage(systemName: "trash")

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let model = habitModels[indexPath.section]

        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }

            openEditHabit(model: model)
            completion(true)
        }

        editAction.backgroundColor = .systemBlue
        editAction.image = UIImage(systemName: "square.and.pencil")

        let configuration = UISwipeActionsConfiguration(actions: [editAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let model = habitModels[indexPath.section]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let editAction = UIAction(
                title: "Edit",
                image: UIImage(systemName: "square.and.pencil")
            ) { _ in
                self?.openEditHabit(model: model)
            }

            let deleteAction = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.confirmDeleteHabit(model: model)
            }

            return UIMenu(children: [editAction, deleteAction])
        }
    }
}
