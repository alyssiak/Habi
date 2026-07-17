//
//  MainTabBarController.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 10.07.2026.
//

import Foundation
import UIKit

final class MainTabBarController: UITabBarController {
    init(viewControllers: [UIViewController]) {
        super.init(nibName: nil, bundle: nil)
        self.viewControllers = viewControllers
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupAppearance() {
        tabBar.tintColor = .appOrange
        tabBar.backgroundColor = .appBackground
    }
}
