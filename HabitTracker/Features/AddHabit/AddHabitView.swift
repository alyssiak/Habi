//
//  AddHabitView.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 07.05.2026.
//

import UIKit
import SnapKit

final class AddHabitView: UIView {
    var titleTextField = UITextField()
    var emojiCollectionView: UICollectionView
    var colorCollectionView: UICollectionView
    var saveButton = UIButton()
    
    override init(frame: CGRect) {
        let emojiLayout = UICollectionViewFlowLayout()
        emojiLayout.scrollDirection = .horizontal
        emojiLayout.itemSize = CGSize(width: 44, height: 44)
        emojiLayout.minimumLineSpacing = 8
        
        let colorLayout = UICollectionViewFlowLayout()
        colorLayout.scrollDirection = .horizontal
        colorLayout.itemSize = CGSize(width: 44, height: 44)
        colorLayout.minimumLineSpacing = 8
        
        self.emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: emojiLayout)
        self.colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: colorLayout)
        
        super.init(frame: frame)
        backgroundColor = .white
        
        setupView()
        setupContent()
        setupConstraints()
    }
    
    
    required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        emojiCollectionView.backgroundColor = .clear
        colorCollectionView.backgroundColor = .clear
        
        emojiCollectionView.showsHorizontalScrollIndicator = false
        colorCollectionView.showsHorizontalScrollIndicator = false
        
        emojiCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EmojiCollectionViewCell")
        colorCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ColorCollectionViewCell")
        
        titleTextField.placeholder = "Read a bo.."
        titleTextField.font = UIFont(name: "Montserrat-Regular", size: 18)
        titleTextField.borderStyle = .roundedRect
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 18)
        saveButton.layer.cornerRadius = 10
    }
    
    private func setupContent() {
        addSubview(emojiCollectionView)
        addSubview(colorCollectionView)
        addSubview(titleTextField)
        addSubview(saveButton)
    }
    
    private func setupConstraints() {
        emojiCollectionView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(emojiCollectionView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        colorCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        
        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(150)
        }
    }
}
