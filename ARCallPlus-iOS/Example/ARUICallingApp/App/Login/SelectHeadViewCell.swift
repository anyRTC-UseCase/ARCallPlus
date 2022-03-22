//
//  SelectHeadViewCell.swift
//  ARUICallingApp
//
//  Created by 余生 on 2022/3/9.
//

import UIKit

class SelectHeadViewCell: UICollectionViewCell {
    static let reuseIdentifier = "SelectCollectionViewCell_Reuse_Identifier"
    
    private var isViewReady = false
    private var buttonAction: (() -> Void)?
    
    override var isSelected: Bool {
        didSet {
            headImageView.layer.borderColor = UIColor(hexString: isSelected ? "#294BFF" : "#EBEBF3")?.cgColor
        }
    }
    
    lazy var headImageView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = 8
        img.layer.borderColor = UIColor(hexString: "#EBEBF3")?.cgColor
        img.layer.borderWidth = 1.0
        img.layer.masksToBounds = true
        return img
    }()
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        isViewReady = true
        contentView.addSubview(headImageView)
        headImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.buttonAction = nil
    }
}
