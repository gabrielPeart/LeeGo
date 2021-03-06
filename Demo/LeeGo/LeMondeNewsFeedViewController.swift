//
//  LeMondeNewsFeedViewController.swift
//  LeeGo
//
//  Created by Victor WANG on 27/02/16.
//  Copyright © 2016 LeeGo. All rights reserved.
//

import Foundation
import UIKit

class LeMondeNewsFeedViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            for reuseId in LeMonde.cellReuseIdentifiers {
                collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseId)
            }
        }
    }

    private var elements = [ElementViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        if elements.isEmpty {
            let URLRequest =  NSURLRequest(URL: NSURL(string: "http://api-cdn.lemonde.fr/ws/6/mobile/www/ios-phone/en_continu/index.json")!)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(URLRequest) {data, response, error in
                if let data = data,
                    let optionalValue = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? Dictionary<String, AnyObject>,
                    let value = optionalValue,
                    let elementDictionaries = value["elements"] as? Array<Dictionary<String, AnyObject>> {
                        self.elements = ElementViewModel.elementViewModelsWithElements(Element.elementsFromDictionaries(elementDictionaries))
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.collectionView.reloadData()
                        })
                }
            }

            task.resume()
        }

        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).estimatedItemSize = CGSizeMake(self.view.frame.width, 180)
    }

    // MARK: Collection View DataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return elements.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        var brick = indexPath.row % 2 == 0 ? LeMonde.standard.brick() : LeMonde.featured.brick()

        if elements[indexPath.row].element.type == "live" {
            brick = LeMonde.live.brick()
        }

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(brick.name, forIndexPath: indexPath)

        cell.lg_configureAs(brick, dataSource: elements[indexPath.item], updatingStrategy: .Always)

        return cell
    }

    // MARK: Collection View Layout

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.5
    }

    // MARK: size
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ (context) -> Void in
            (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).estimatedItemSize = CGSizeMake(self.view.frame.width, 180)
            self.collectionView.reloadData()
            }, completion: nil)

        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
}

extension UICollectionViewCell {
    override public func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {

        return lg_fittingHeightLayoutAttributes(layoutAttributes)
    }
}