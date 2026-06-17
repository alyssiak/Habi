//
//  HabitCalendarView.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 04.05.2026.
//

import UIKit
import SnapKit

final class HabitCalendarView: UIView {
    private let mainStackView = UIStackView()
    
    private enum Layout {
        static let cellSize: CGFloat = 7
        static let cellCornerRadius: CGFloat = 2.5
        static let itemSpacing: CGFloat = 2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
        setupConstraints()
    }
    
    func configure(days: [HabitCalendarDay]) {
        UIView.performWithoutAnimation {
            mainStackView.arrangedSubviews.forEach {
                mainStackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
            
            let rows = days.chunked(into: 7)
            
            rows.forEach { row in
                let rowStackView = UIStackView()
                rowStackView.axis = .horizontal
                rowStackView.distribution = .fillEqually
                rowStackView.alignment = .center
                rowStackView.spacing = Layout.itemSpacing
                
                row.forEach { day in
                    let dayView = UIView()
                    
                    dayView.layer.cornerRadius = Layout.cellCornerRadius
                    dayView.snp.makeConstraints { make in
                        make.height.width.equalTo(Layout.cellSize)
                    }
                    
                    switch day.state {
                    case .future:
                        dayView.backgroundColor = .nextDaysGray
                    case .completed:
                        dayView.backgroundColor = .appOrange
                    case .missed:
                        dayView.backgroundColor = .lastDaysGray
                    }
                    
                    rowStackView.addArrangedSubview(dayView)
                }
                
                while rowStackView.arrangedSubviews.count < 7 {
                    let emptyView = UIView()
                    
                    emptyView.backgroundColor = .clear
                    emptyView.snp.makeConstraints { make in
                        make.height.width.equalTo(Layout.cellSize)
                    }
                    
                    rowStackView.addArrangedSubview(emptyView)
                }
                
                mainStackView.addArrangedSubview(rowStackView)
            }
            
            layoutIfNeeded()
        }
    }
    
    private func setupView() {
        clipsToBounds = true
        
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill
        mainStackView.spacing = Layout.itemSpacing
        
        addSubview(mainStackView)
    }
    
    private func setupConstraints() {
        mainStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}
