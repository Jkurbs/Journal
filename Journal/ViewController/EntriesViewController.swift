//
//  EntriesViewController.swift
//  Journal
//
//  Created by Kerby Jean on 4/28/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit
import SweetCurtain

class EntriesViewController: UIViewController {
    
    var label = UILabel()
    var button = UIButton()
    lazy var collectionView = UICollectionView()
    var entries = [Entry]()
    var heightConstraintValue: CGFloat = 200

    var collectionViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    // MARK: - Functions
    
    func setupViews() {
        view.backgroundColor = .darkness
        self.navigationController?.view.layer.cornerRadius = 10.0
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        
        let font = UIFont.systemFont(ofSize: 15, weight: .bold)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = font
        label.textColor = .cloud
        view.addSubview(label)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = font
        view.addSubview(button)

        let layout = UICollectionViewFlowLayout()
        let width = (view.frame.width / 3) - 10
        layout.itemSize = CGSize(width: width, height: width + 20)
        layout.sectionInset = UIEdgeInsets(top: 25, left: 10, bottom: 50, right: 10)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .darkness
        collectionView.register(EntryCell.self, forCellWithReuseIdentifier: EntryCell.id)
        view.addSubview(collectionView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 16.0),
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0),
            
            button.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0),
            
            collectionView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8.0),
            collectionView.widthAnchor.constraint(equalTo: view.widthAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
}

// MARK: - CurtainDelegate
extension EntriesViewController: CurtainDelegate {
    
    func curtain(_ curtain: Curtain, didChange heightState: CurtainHeightState) {
        switch heightState {
        case .min:
            label.text = nil
            button.setTitle("", for: .normal)
        case .mid:
            label.text = "5 entries"
            button.setTitle("Add to Journal", for: .normal)
            guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
            let width = (view.frame.width / 3) - 10
            layout.itemSize = CGSize(width: width, height: width + 20)
            layout.prepare()
            layout.invalidateLayout()
        case .max:
            label.text = "All Entries"
            guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
            layout.itemSize = CGSize(width: view.frame.width - 20, height: 150)
            layout.prepare()
            layout.invalidateLayout()
        default:
            break
        }
    }
    
    func curtainWillBeginDragging(_ curtain: Curtain) {
        
    }
}

extension EntriesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EntryCell.id, for: indexPath) as! EntryCell
        cell.backgroundColor = .cloud
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        curtainController?.moveCurtain(to: .max, animated: true)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
}
