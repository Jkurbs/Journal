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
    var collectionViewTopConstraint: NSLayoutConstraint?
    
    var textView = UITextView()
    
    var voiceWaveView = VoiceWaveView()
    var recordButtonView = RecordButtonView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    // MARK: - Functions
    
    func setupViews() {
        view.backgroundColor = .darkness
        self.navigationController?.view.layer.cornerRadius = 10.0
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(voiceWaveView)
        view.addSubview(recordButtonView)

//        let font = UIFont.systemFont(ofSize: 13, weight: .bold)
        
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = font
//        label.textColor = .cloud
//        view.addSubview(label)
//
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setTitleColor(.systemBlue, for: .normal)
//        button.titleLabel?.font = font
//        view.addSubview(button)
//
//        label.isHidden = true
//        button.isHidden = true
        

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
        self.curtainController?.moveCurtain(to: .mid, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            voiceWaveView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0),
            voiceWaveView.widthAnchor.constraint(equalTo: view.widthAnchor),
            voiceWaveView.heightAnchor.constraint(equalToConstant: 40),
            
            recordButtonView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButtonView.topAnchor.constraint(equalTo: voiceWaveView.bottomAnchor, constant: 8.0),
            recordButtonView.widthAnchor.constraint(equalTo: view.widthAnchor),
            recordButtonView.heightAnchor.constraint(equalToConstant: 100.0),
            
//            button.centerYAnchor.constraint(equalTo: label.centerYAnchor),
//            button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0),
//
            collectionView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        collectionViewTopConstraint = collectionView.topAnchor.constraint(equalTo: recordButtonView.bottomAnchor, constant: 0.0)
        collectionViewTopConstraint?.isActive = true

        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 200)
        collectionViewHeightConstraint?.isActive = true
    }
}

// MARK: - CurtainDelegate
extension EntriesViewController: CurtainDelegate {
    
    
    func curtain(_ curtain: Curtain, didChange heightState: CurtainHeightState) {
        switch heightState {
        case .min:
            self.voiceWaveView.alpha = 1.0
            self.recordButtonView.alpha = 1.0
            UIView.animate(withDuration: 0.5) {
                self.collectionViewTopConstraint?.constant -= (self.voiceWaveView.frame.size.height + self.recordButtonView.frame.size.height)
            }
        case .mid:
            guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
            let width = (view.frame.width / 3) - 10
            layout.itemSize = CGSize(width: width, height: width + 20)
            layout.prepare()
            layout.invalidateLayout()
            UIView.animate(withDuration: 0.5) {
                self.collectionViewHeightConstraint?.constant = 200
                self.collectionViewTopConstraint?.constant += (self.voiceWaveView.frame.size.height + self.recordButtonView.frame.size.height)
                self.collectionView.layoutIfNeeded()
            }
//            UIView.animate(withDuration: 0.3) {
//                self.collectionViewHeightConstraint?.constant = 200
//                self.collectionViewTopConstraint?.constant = -(self.voiceWaveView.frame.size.height + self.recordButtonView.frame.size.height)
//                self.collectionView.layoutIfNeeded()
//            }
            
        case .max:
            guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
            let width = (view.frame.width) - 15
            layout.itemSize = CGSize(width: width, height: 250)
            layout.prepare()
            layout.invalidateLayout()
            
            let height = self.collectionView.collectionViewLayout.collectionViewContentSize.height
            UIView.animate(withDuration: 0.3) {
                self.voiceWaveView.alpha = 0.0
                self.recordButtonView.alpha = 0.0
                self.collectionViewHeightConstraint?.constant = height + 100
                self.collectionViewTopConstraint?.constant -= (self.voiceWaveView.frame.size.height + self.recordButtonView.frame.size.height)
                self.collectionView.layoutIfNeeded()
            }

        default:
            break
        }
    }

    func curtainDidDrag(_ curtain: Curtain) {
        NotificationCenter.default.post(name: .dimCameraNotification, object: nil, userInfo: ["alpha": curtain.heightCoefficient])
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
