//
//  EntriesViewController.swift
//  Journal
//
//  Created by Kerby Jean on 4/28/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit
import SweetCurtain
import PXSiriWave

class EntriesViewController: UIViewController {
    
    var label = UILabel()
    var button = UIButton()
    lazy var collectionView = UICollectionView()
    var entries = [Entry]()
    var heightConstraint: CGFloat = 200
    var collectionViewHeightConstraint: NSLayoutConstraint?
    
    var textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    // MARK: - Functions
    
    func setupViews() {
        view.backgroundColor = .darkness
        self.navigationController?.view.layer.cornerRadius = 10.0
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let font = UIFont.systemFont(ofSize: 13, weight: .bold)
        
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
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .darkness
        collectionView.register(EntryCell.self, forCellWithReuseIdentifier: EntryCell.id)
        view.addSubview(collectionView)
        
        textView.frame = CGRect(x: 0, y: 350, width: view.frame.width, height: 500)
        textView.backgroundColor = .darkness
        textView.textColor = .white
        textView.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        view.addSubview(textView)
        
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 16.0),
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10.0),
            
            button.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0),
            
            collectionView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8.0),
            collectionView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 200)
        collectionViewHeightConstraint?.isActive = true
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
            UIView.animate(withDuration: 0.3) {
                self.collectionViewHeightConstraint?.constant = 200
                self.collectionView.layoutIfNeeded()
            }
            
        case .max:
            label.text = "All Entries"
            guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
            let width = (view.frame.width) - 15
            layout.itemSize = CGSize(width: width, height: 250)
            layout.prepare()
            layout.invalidateLayout()
            let height = self.collectionView.collectionViewLayout.collectionViewContentSize.height
            UIView.animate(withDuration: 0.3) {
                self.collectionViewHeightConstraint?.constant = height + 100
                self.collectionView.layoutIfNeeded()
            }
        default:
            break
        }
    }
    
    func curtainDidDrag(_ curtain: Curtain) {
        NotificationCenter.default.post(name: NSNotification.Name("test"), object: nil, userInfo: ["alpha": curtain.heightCoefficient])
    }
}

extension EntriesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EntryCell.id, for: indexPath) as! EntryCell
        cell.contentView.backgroundColor = UIColor(red: 19.0/255.0, green: 33.0/255.0, blue: 46.0/255.0, alpha: 0.5)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        curtainController?.moveCurtain(to: .max, animated: true)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
}
