//
//  AddHabitViewController.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 07.05.2026.
//

import UIKit
import SnapKit

final class AddHabitViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
   
    
    private let emojiList = ["🔥", "📚", "💧", "🏃‍♀️", "🧘‍♀️", "🎯", "🍎"]
    private let colorList = ColorPalettes.ColorPalette
    private let addHabitView = AddHabitView()
    private var selectedEmoji: String?
    private var selectedColor: String?
    
    private let viewModel: HabitTrackerViewModel
    
    var onHabitAdded: (() -> Void)?
    
    init(viewModel: HabitTrackerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedEmoji = emojiList.first
        selectedColor = colorList.first?.hex
        
        addHabitView.emojiCollectionView.delegate = self
        addHabitView.colorCollectionView.delegate = self
        
        addHabitView.emojiCollectionView.dataSource = self
        addHabitView.colorCollectionView.dataSource = self
        
        addHabitView.saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === addHabitView.emojiCollectionView {
            selectedEmoji = emojiList[indexPath.item]
        } else {
            selectedColor = colorList[indexPath.item].hex
        }
        
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === addHabitView.emojiCollectionView {
            return emojiList.count
        }
        
        return colorList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === addHabitView.emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCollectionViewCell", for: indexPath)
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            let label = UILabel()
            label.text = emojiList[indexPath.item]
            label.font = .systemFont(ofSize: 30)
            label.textAlignment = .center
            cell.contentView.addSubview(label)
            label.frame = cell.contentView.bounds
            cell.contentView.layer.cornerRadius = 24
            cell.contentView.backgroundColor = emojiList[indexPath.item] == selectedEmoji ? .systemGray5 : .clear
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCollectionViewCell", for: indexPath)
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            let color = colorList[indexPath.item]
            cell.contentView.backgroundColor = color.uiColor
            cell.contentView.layer.cornerRadius = 20
            cell.contentView.layer.masksToBounds = true
            cell.contentView.layer.borderWidth = color.hex == selectedColor ? 3 : 0
            cell.contentView.layer.borderColor = UIColor.label.cgColor
            return cell
        }
        
       
    }
    
    @objc private func didTapSave() {
        let title = addHabitView.titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !title.isEmpty else { return }
        
        viewModel.addHabit(
            title: title,
            emoji: selectedEmoji,
            colorHex: selectedColor
        )
        
        onHabitAdded?()
        // закрыть экран
        dismiss(animated: true)
    }
    
    override func loadView() {
        view = addHabitView
    }
}
