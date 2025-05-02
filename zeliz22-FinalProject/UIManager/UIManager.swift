//
//  UIManager.swift
//  zeliz22-FinalProject
//
//  Created by zaza elizbarashvili on 06/12/1403 AP.
//

import Foundation
import UIKit

class UIManager {
    weak var viewController: ViewController?
    
    init(viewController: ViewController) {
        self.viewController = viewController
    }
    
    func setupUI() {
        guard let viewController = viewController else { return }
        
        viewController.view.backgroundColor = UIColor(red: 0.25, green: 0.38, blue: 0.58, alpha: 1.0)
        viewController.title = "Weather App"

        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: viewController,
            action: #selector(viewController.addCity)
        )
        
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: viewController,
            action: #selector(viewController.refreshWeather)
        )

        // Set up page control
        viewController.view.addSubview(viewController.pageControl)
        viewController.pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.pageControl.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            viewController.pageControl.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor)
        ])
        
        // Set up collection view
        viewController.view.addSubview(viewController.collectionView)
        viewController.collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.collectionView.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor, constant: 50),
            viewController.collectionView.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            viewController.collectionView.leadingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.leadingAnchor),
            viewController.collectionView.trailingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        // Long press gesture
        let longPressGesture = UILongPressGestureRecognizer(
            target: viewController,
            action: #selector(viewController.handleLongPress)
        )
        viewController.collectionView.addGestureRecognizer(longPressGesture)
        
        // Activity indicator
        viewController.view.addSubview(viewController.activityIndicator)
        viewController.activityIndicator.center = viewController.view.center
    }
    
    
    
    func setupNavigationBarAppearance() {
        guard let viewController = viewController,
              let navigationController = viewController.navigationController else { return }
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            
            appearance.backgroundColor = UIColor(red: 0.25, green: 0.38, blue: 0.58, alpha: 1.0)
            
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 20, weight: .bold)
            ]
            
            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance
            navigationController.navigationBar.compactAppearance = appearance
            navigationController.navigationBar.isTranslucent = false
        } else {
            navigationController.navigationBar.barTintColor = UIColor(red: 0.25, green: 0.38, blue: 0.58, alpha: 1.0)
            navigationController.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 20, weight: .bold)
            ]
            navigationController.navigationBar.isTranslucent = false
        }
        
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.tintColor = .yellow
    }
}
