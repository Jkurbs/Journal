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

class EntriesViewController: UIViewController {
    
    var entries = [Entry]()
    var voiceWaveView = VoiceWaveView()
    
    lazy var adapter: ListAdapter = {
        ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    
    var collectionView: UICollectionView!
    
    lazy var wideCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.scrollDirection = .horizontal
        view.showsHorizontalScrollIndicator = false
        view.isPagingEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
    
        view.isHidden = true
        self.view.addSubview(view)
        return view
    }()
    
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
        view.backgroundColor = .darkness
        self.navigationController?.view.layer.cornerRadius = 10.0
        self.navigationItem.titleView = voiceWaveView
        voiceWaveView.autoresizingMask = .flexibleWidth
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        adapter.collectionView = wideCollectionView
        adapter.dataSource = self
        
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
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            voiceWaveView.heightAnchor.constraint(equalToConstant: self.navigationController?.navigationBar.frame.height ?? 40),
            voiceWaveView.widthAnchor.constraint(equalToConstant: 100),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.widthAnchor.constraint(equalTo: view.widthAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 200),
            
            wideCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            wideCollectionView.widthAnchor.constraint(equalTo: view.widthAnchor),
            wideCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
    
    func loadData() {
        DataService.shared.observeEntries { result in
            self.entries.removeAll()
            if let entry = try? result.get() as? Entry {
                DispatchQueue.main.async {
                    self.entries.append(entry)
                    self.collectionView.reloadData()
                    self.adapter.performUpdates(animated: true, completion: nil)
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
            print("")
            collectionView.isHidden = false
            wideCollectionView.isHidden = true
        case .max:
            collectionView.isHidden = true
            wideCollectionView.isHidden = false
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
        return entries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EntryCell.id, for: indexPath) as! EntryCell
        cell.contentView.backgroundColor = UIColor(red: 19.0/255.0, green: 33.0/255.0, blue: 46.0/255.0, alpha: 0.5)
        let entry = self.entries[indexPath.row]
        cell.entry = entry
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let cell = collectionView.cellForItem(at: indexPath) as! EntryCell
        curtainController?.moveCurtain(to: .max, animated: true)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        cell.playVideo()
    }
}

extension EntriesViewController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return entries as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return EntryController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
