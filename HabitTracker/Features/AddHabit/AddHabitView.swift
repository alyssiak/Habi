//
//  AddHabitView.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 07.05.2026.
//

import UIKit
import SnapKit

final class AddHabitView: UIView {
    //MARK: - Properties
    
    var titleTextField = UITextField()
    var emojiCollectionView: UICollectionView
    var colorCollectionView: UICollectionView
    var saveButton = UIButton()
    let screenTitleLabel = UILabel()
    let cancelButton = UIButton(type: .system)
    let titleErrorLabel = UILabel()
    let descriptionTitleLabel = UILabel()
    let descriptionTextView = UITextView()
    let descriptionPlaceholderLabel = UILabel()
    let emojiTitleLabel = UILabel()
    let nameTitleLabel = UILabel()
    let colorTitleLabel = UILabel()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    //MARK: - Init
    override init(frame: CGRect) {
        let emojiLayout = UICollectionViewFlowLayout()
        emojiLayout.scrollDirection = .horizontal
        emojiLayout.itemSize = CGSize(width: 44, height: 44)
        emojiLayout.minimumLineSpacing = 8
        
        let colorLayout = UICollectionViewFlowLayout()
        colorLayout.scrollDirection = .horizontal
        colorLayout.itemSize = CGSize(width: 56, height: 56)
        colorLayout.minimumLineSpacing = 12
        colorLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        self.emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: emojiLayout)
        self.colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: colorLayout)
        
        super.init(frame: frame)
        
        setupView()
        setupContent()
        setupConstraints()
    }
    
    
    required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private Methods
    private func setupView() {
        backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.label, for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 13)
       
        screenTitleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 16)
        screenTitleLabel.textColor = .label
        screenTitleLabel.textAlignment = .center
        
        emojiCollectionView.backgroundColor = .clear
        colorCollectionView.backgroundColor = .clear
        
        emojiCollectionView.showsHorizontalScrollIndicator = false
        colorCollectionView.showsHorizontalScrollIndicator = false
        
        emojiCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EmojiCollectionViewCell")
        colorCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ColorCollectionViewCell")
        
        titleTextField.placeholder = "Habit name"
        titleTextField.font = UIFont(name: "Montserrat-Regular", size: 18)
        titleTextField.borderStyle = .roundedRect
        
        titleErrorLabel.text = "Enter habit name"
        titleErrorLabel.textColor = .systemRed
        titleErrorLabel.font = UIFont(name: "Montserrat-Medium", size: 12)
        titleErrorLabel.isHidden = true
        
        descriptionTitleLabel.text = "Description"
        descriptionTitleLabel.font = UIFont(name: "Montserrat-Medium", size: 14)
        descriptionTitleLabel.textColor = .secondaryLabel
        
        descriptionTextView.font = UIFont(name: "Montserrat-Regular", size: 16)
        descriptionTextView.textColor = .label
        descriptionTextView.backgroundColor = .secondarySystemBackground
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.textContainerInset = UIEdgeInsets(
            top: 10,
            left: 8,
            bottom: 10,
            right: 8
        )
        
        descriptionPlaceholderLabel.text = "Add a short note"
        descriptionPlaceholderLabel.font = UIFont(name: "Montserrat-Regular", size: 16)
        descriptionPlaceholderLabel.textColor = .tertiaryLabel
        
        configureSectionTitle(emojiTitleLabel, text: "Emoji")
        configureSectionTitle(nameTitleLabel, text: "Habit name")
        configureSectionTitle(descriptionTitleLabel, text: "Description")
        configureSectionTitle(colorTitleLabel, text: "Color")

        titleTextField.placeholder = "e.g. Morning run"
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.layer.cornerRadius = 14
        saveButton.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 17)
        saveButton.layer.cornerRadius = 10
    }
    
    private func setupContent() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(cancelButton)
        contentView.addSubview(screenTitleLabel)
        contentView.addSubview(emojiTitleLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorTitleLabel)
        contentView.addSubview(colorCollectionView)
        contentView.addSubview(nameTitleLabel)
        contentView.addSubview(titleTextField)
        contentView.addSubview(titleErrorLabel)
        contentView.addSubview(descriptionTitleLabel)
        contentView.addSubview(descriptionTextView)
        descriptionTextView.addSubview(descriptionPlaceholderLabel)
        contentView.addSubview(saveButton)
    }
    
    private func setupConstraints() {
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(12)
            make.leading.equalToSuperview().inset(20)
        }

        screenTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(cancelButton.snp.centerY)
            make.centerX.equalToSuperview()
        }
        
        emojiTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(screenTitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        emojiCollectionView.snp.makeConstraints { make in
            make.top.equalTo(emojiTitleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        
        nameTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(emojiCollectionView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTitleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        titleErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(4)
            make.leading.trailing.equalTo(titleTextField)
        }
        
        descriptionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleErrorLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(descriptionTitleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(96)
        }
        
        descriptionPlaceholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(12)
            make.trailing.lessThanOrEqualToSuperview().inset(12)
        }
        
        colorTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        colorCollectionView.snp.makeConstraints { make in
            make.top.equalTo(colorTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(64)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(colorCollectionView.snp.bottom).offset(36)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(contentView.snp.bottom).offset(-24)
            make.height.equalTo(52)
        }
    }
    
    //MARK: - Helpers
    private func configureSectionTitle(_ label: UILabel, text: String) {
        label.text = text
        label.font = UIFont(name: "Montserrat-Medium", size: 14)
        label.textColor = .nextDaysGray
    }
}
