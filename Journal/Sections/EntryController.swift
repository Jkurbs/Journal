//
//  EntryController.swift
//  Journal
//
//  Created by Kerby Jean on 4/30/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit
import IGListKit

class EntryController: ListSectionController {
    
    private var entry: Entry?
    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext!.containerSize.width
        let height = collectionContext!.containerSize.height
        if index == 0 {
            return CGSize(width: width, height: height - 200)
        } else {
            return CGSize(width: width, height: 100)
        }
    }
    
    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func numberOfItems() -> Int {
        2
    }
    
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        if index == 0 {
            guard let cell = collectionContext?.dequeueReusableCell(of: EntryCell.self, for: self, at: index) as? EntryCell else {
                fatalError()
            }
            cell.entry = entry
            return cell
        } else {
            guard let cell = collectionContext?.dequeueReusableCell(of: SpeechCell.self, for: self, at: index) as? SpeechCell else {
                fatalError()
            }
            cell.text = entry?.speech
            return cell
        }
    }
    
    override func didUpdate(to object: Any) {
        self.entry = object as? Entry
    }
    
    override func didSelectItem(at index: Int) {
        if let cell = collectionContext?.cellForItem(at: index, sectionController: self) as? EntryCell {
            cell.playVideo()
        }
    }
}
