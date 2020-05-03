//
//  EntriesViewController.swift
//  Journal
//
//  Created by Kerby Jean on 4/28/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit
import IGListKit
import SweetCurtain
import AVFoundation

class EntriesViewController: UIViewController {
    
    // MARK: - Properties
    
    var entries = [Entry]()
    var voiceWaveView = VoiceWaveView()
    
    lazy var adapter: ListAdapter = {
        ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    var collectionView: UICollectionView!
    var playerView = PlayerView()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupConstraints()
    }
    
    // MARK: - Functions
    
    func setupViews() {
        
        view.backgroundColor = .black
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
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
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .black
        collectionView.register(EntryCell.self, forCellWithReuseIdentifier: EntryCell.id)
        view.addSubview(collectionView)
        
        playerView = PlayerView(frame: view.frame)
        view.addSubview(playerView)
                
        NotificationCenter.default.addObserver(self, selector: #selector(addNewEntry), name: NSNotification.Name("testentry"), object: nil)
    }
    
    @objc func addNewEntry(_ notification: Notification) {
        if let info = notification.userInfo, let entry = info["entry"] as? Entry {
            self.loadData()
        }
    }
    
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            voiceWaveView.heightAnchor.constraint(equalToConstant: self.navigationController?.navigationBar.frame.height ?? 40),
            voiceWaveView.widthAnchor.constraint(equalToConstant: 100),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.widthAnchor.constraint(equalTo: view.widthAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 200),
        ])
    }
    
    func loadData() {
        self.entries.removeAll()
        DataService.shared.observeEntries { result in
            if let entry = try? result.get() as? Entry {
                DispatchQueue.main.async {
                    self.entries.append(entry)
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

// MARK: - CurtainDelegate

extension EntriesViewController: CurtainDelegate {
    
    func curtain(_ curtain: Curtain, didChange heightState: CurtainHeightState) {
        switch heightState {
        case .min:
            print("")
        case .mid:
            playerView.player.pause()
            collectionView.isHidden = false
            playerView.isHidden = true
        case .max:
            collectionView.isHidden = true
            playerView.isHidden = false
            guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return }
            let entry = self.entries[indexPath.row]
            
            DispatchQueue.main.async {
                self.playerView.configure(entry)
            }
        default:
            break
        }
    }
    
    func curtainDidDrag(_ curtain: Curtain) {
        NotificationCenter.default.post(name: .dimCameraNotification, object: nil, userInfo: ["alpha": curtain.heightCoefficient])
    }
}


// MARK: - UICollectionViewDataSource

extension EntriesViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return entries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EntryCell.id, for: indexPath) as! EntryCell
        cell.contentView.backgroundColor = .midnightBlue
        let entry = self.entries[indexPath.row]
        cell.entry = entry
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        
        curtainController?.moveCurtain(to: .max, animated: true)
    }
}
