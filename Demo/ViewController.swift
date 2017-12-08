//
//  ViewController.swift
//  Demo
//
//  Created by 叶落沉香 on 11/10/2017.
//  Copyright © 2017 Magic. All rights reserved.
//

import UIKit
import SMWaterFlowLayout

extension CGFloat {
    static func random(_ mold: CGFloat = 100000, decimal: CGFloat = 3) -> CGFloat {
        let ten = pow(10, decimal)
        let ft = arc4random_uniform(UInt32(mold * ten))
        return CGFloat(ft) / ten
    }
}

class ViewController: UICollectionViewController, SMWaterFlowLayoutDelegate {
    var arr: [CGFloat] = (10 ... 100).map {_ in CGFloat.random(1) }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        title = "Demo"

        let ly = collectionViewLayout as? SMWaterFlowLayout
        ly?.lineCount = 3
        ly?.scrollDirection = .vertical
        ly?.lineSpacing = 10
        ly?.interitemSpacing = 10
        ly?.edgeInset = UIEdgeInsets(top: 20, left: 30, bottom: 40, right: 50)
        ly?.headerViewLength = HeaderV.size.height
        ly?.footerViewLength = HeaderV.size.height

        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.description())
        collectionView?.register(HeaderV.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HeaderV.description())
        collectionView?.register(HeaderV.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: HeaderV.description())
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged(not:)), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc func orientationChanged(not: Notification) {
        let orientation = UIDevice.current.orientation
        let ly = collectionViewLayout as? SMWaterFlowLayout
        switch orientation {
        case .portrait: fallthrough
        case .portraitUpsideDown:
            ly?.lineCount = 3
        case .landscapeLeft: fallthrough
        case .landscapeRight:
            ly?.lineCount = 4
        case .faceUp: break
        case .faceDown: break
        case .unknown: break
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.description(), for: indexPath)
        cell.backgroundColor = UIColor(hue: CGFloat.random(255) / 255, saturation: 1, brightness: 1, alpha: 1)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: SMWaterFlowLayout, constantLength: CGFloat, variableLengthForItemAt indexPath: IndexPath) -> CGFloat {
        let aspect = arr[indexPath.row]
        return constantLength * aspect
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sview = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                    withReuseIdentifier: HeaderV.description(),
                                                                    for: indexPath)
        guard let view = sview as? HeaderV else { return sview }
        view.lb.text = "Sample"
        return view
    }
}
