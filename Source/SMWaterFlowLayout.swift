//
//  SMWaterfallFlowLayout.swift
//  SuperMe
//
//  Created by Magic on 10/10/2017.
//  Copyright © 2017 SuperMe. All rights reserved.
//

import Foundation
import UIKit

public protocol SMWaterFlowLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: SMWaterFlowLayout, constantLength: CGFloat, variableLengthForItemAt indexPath: IndexPath) -> CGFloat
}

public class SMWaterFlowLayout: UICollectionViewLayout {
    private let keyPathCollection = #keyPath(UICollectionViewLayout.collectionView)
    private let keyPathDelegate = #keyPath(UICollectionView.delegate)
    fileprivate var didAddDelegate = false

    fileprivate var attArr: [UICollectionViewLayoutAttributes] = []
    fileprivate var supplementaryAtts: [UICollectionViewLayoutAttributes] = []
    fileprivate var lineHeightArr: [CGFloat] = [0]
    fileprivate var lineLength: CGFloat = 0

    open var scrollDirection: UICollectionViewScrollDirection = .vertical
    open var lineCount: Int = 3
    open var lineSpacing: CGFloat = 0
    open var interitemSpacing: CGFloat = 0
    open var edgeInset: UIEdgeInsets = .zero
    open var headerViewLength: CGFloat = 0
    open var footerViewLength: CGFloat = 0

    fileprivate weak var delegate: SMWaterFlowLayoutDelegate?

    public override init() {
        super.init()

        addObserver(self, forKeyPath: keyPathCollection, options: [.new, .old], context: nil)
        manage(collectionView: collectionView)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        removeObserver(self, forKeyPath: keyPathCollection)
        if didAddDelegate { collectionView?.removeObserver(self, forKeyPath: keyPathDelegate) }
    }

    override public func prepare() {
        super.prepare()
        resetLineInfo()

        guard
            let collectV = collectionView,
            let dataSource = collectV.dataSource
        else { return }

        attArr.removeAll()
        let sectionCount = dataSource.numberOfSections?(in: collectV) ?? 1
        for section in 0 ..< sectionCount {
            let itemCount = dataSource.collectionView(collectV, numberOfItemsInSection: section)
            for row in 0 ..< itemCount {
                let att = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: row, section: section))

                modify(layout: att)
                attArr.append(att)
            }
        }

        if headerViewLength > 0 {
            let header = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(item: 0, section: 0))
            header.frame.size = makeSize(length: headerViewLength)
            supplementaryAtts.append(header)
        }

        if footerViewLength > 0 {
            let footer = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: IndexPath(item: 0, section: 1))
            footer.frame.size = makeSize(length: footerViewLength)
            let length = caculateMaxLength() - footerViewLength
            switch scrollDirection {
            case .horizontal: footer.frame.origin = CGPoint(x: length, y: 0)
            case .vertical: footer.frame.origin = CGPoint(x: 0, y: length)
            }
            supplementaryAtts.append(footer)
        }
    }

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let kp = keyPath else { return }
        switch kp {
        case keyPathCollection:
            let new = change?[.newKey] as? UICollectionView
            let old = change?[.oldKey] as? UICollectionView
            if didAddDelegate, let v = old {
                v.removeObserver(self, forKeyPath: keyPathDelegate)
                didAddDelegate = false
            }
            manage(collectionView: new)
        case keyPathDelegate: manage(delegate: change?[.newKey] as? UICollectionViewDelegate)
        default: break
        }
    }

    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attArr[indexPath.item]
    }

    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attArr + supplementaryAtts
    }

    override public var collectionViewContentSize: CGSize {
        return makeSize(length: caculateMaxLength())
    }
}

extension SMWaterFlowLayout {
    fileprivate func manage(collectionView view: UICollectionView?) {
        guard let collectV = view else { return }
        collectV.addObserver(self, forKeyPath: keyPathDelegate, options: .new, context: nil)
        didAddDelegate = true
        manage(delegate: collectV.delegate)
    }

    fileprivate func manage(delegate dg: UICollectionViewDelegate?) {
        guard let nDelegate = dg as? SMWaterFlowLayoutDelegate else { return }
        delegate = nDelegate
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
        }
    }

    fileprivate func modify(layout attributes: UICollectionViewLayoutAttributes?) {
        guard
            let att = attributes,
            let collectV = collectionView
            else { return }

        let (index, height) = lineHeightArr.enumerated().min { $0.1 < $1.1 } ?? (0, 0)
        switch scrollDirection {
        case .vertical:
            let x = CGFloat(index) * (lineLength + interitemSpacing) + edgeInset.left
            let y = height
            let height = delegate?.collectionView(collectV, layout: self, constantLength: lineLength, variableLengthForItemAt: att.indexPath) ?? 0
            att.frame = CGRect(x: x, y: y, width: lineLength, height: height)

            lineHeightArr[index] = y + height + lineSpacing
        case .horizontal:
            let x = height
            let y = CGFloat(index) * (lineLength + lineSpacing) + edgeInset.top
            let width = delegate?.collectionView(collectV, layout: self, constantLength: lineLength, variableLengthForItemAt: att.indexPath) ?? 0
            att.frame = CGRect(x: x, y: y, width: width, height: lineLength)

            lineHeightArr[index] = x + width + interitemSpacing
        }
    }

    fileprivate func makeSize(length: CGFloat) -> CGSize {
        switch scrollDirection {
        case .vertical:
            return CGSize(width: collectionWidth, height: length)
        case .horizontal:
            return CGSize(width: length, height: collectionHeight)
        }
    }

    fileprivate func caculateMaxLength() -> CGFloat {
        let length = lineHeightArr.max() ?? 0
        switch scrollDirection {
        case .vertical:
            return length - lineSpacing + edgeInset.bottom + footerViewLength
        case .horizontal:
            return length - interitemSpacing + edgeInset.right + footerViewLength
        }
    }

    fileprivate var collectionWidth: CGFloat {
        return collectionView?.bounds.width ?? 0
    }

    fileprivate var collectionHeight: CGFloat {
        return collectionView?.bounds.height ?? 0
    }

    fileprivate func reset() {
        resetLineInfo()
        invalidateLayout()
    }

    fileprivate func resetLineInfo() {
        lineHeightArr.removeAll()

        switch scrollDirection {
        case .vertical:
            lineCount.forEach { _ in lineHeightArr.append(edgeInset.top + headerViewLength) }
            lineLength = (collectionWidth - edgeInset.left - edgeInset.right - CGFloat(lineCount-1) * interitemSpacing) / CGFloat(lineCount)
        case .horizontal:
            lineCount.forEach { _ in lineHeightArr.append(edgeInset.left + headerViewLength) }
            lineLength = (collectionHeight - edgeInset.top - edgeInset.bottom - CGFloat(lineCount-1) * lineSpacing) / CGFloat(lineCount)
        }
    }
}

extension Int {
    fileprivate func forEach(_ body: (Int) -> Void) {
        (0 ..< self).forEach { (i) in
            body(i)
        }
    }
}
