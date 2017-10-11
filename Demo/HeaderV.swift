//
//  HeaderV.swift
//  Sinostage
//
//  Created by 叶落沉香 on 22/09/2017.
//  Copyright © 2017 SinostageApp. All rights reserved.
//

import Foundation
import UIKit

class HeaderV: UICollectionReusableView {
    override init(frame: CGRect) {
        let rt = CGRect(x: 0, y: 0, width: HeaderV.size.width, height: HeaderV.size.height)
        super.init(frame: rt)

        backgroundColor = UIColor.init(hue: CGFloat(arc4random_uniform(255)) / 255, saturation: 1, brightness: 1, alpha: 1)

        addSubview(lb)
    }

    static let size = CGSize(width: UIScreen.main.bounds.width, height: 77)

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var lb: UILabel = {
        let v = UILabel()
        v.textColor = .red
        v.font = UIFont.systemFont(ofSize: 30)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return v
    }()
}
