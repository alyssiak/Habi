//
//  HabitCalendarView.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 04.05.2026.
//

import UIKit

final class HabitCalendarView: UIView {
    private let mainStackView = UIStackView()
    
    private enum Layout {
        static let cellSize: CGFloat = 7
        static let cellCornerRadius: CGFloat = 2.5
        static let itemSpacing: CGFloat = 3
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
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
                rowStackView.spacing = 2
                
                row.forEach { day in
                    let dayView = UIView()
                    dayView.layer.cornerRadius = 2.5
                    dayView.heightAnchor.constraint(equalToConstant: 7).isActive = true
                    
                    switch day.state {
                    case .future:
                        dayView.backgroundColor = .systemGray5
                    case .completed:
                        dayView.backgroundColor = .systemOrange
                    case .missed:
                        dayView.backgroundColor = .systemGray4
                    }
                    
                    rowStackView.addArrangedSubview(dayView)
                }
                
                while rowStackView.arrangedSubviews.count < 7 {
                    let emptyView = UIView()
                    emptyView.heightAnchor.constraint(equalToConstant: 7).isActive = true
                    emptyView.backgroundColor = .clear
                    
                    rowStackView.addArrangedSubview(emptyView)
                }
                
                mainStackView.addArrangedSubview(rowStackView)
            }
            
            layoutIfNeeded()
        }
    }
    
    private func setupView() {
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill
        mainStackView.spacing = 2
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
        ])
        }
}
