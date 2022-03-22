//
//  MainCollectionViewCell.swift
//  ARUICallingApp
//
//  Created by 余生丶 on 2022/3/4.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "MainCollectionViewCell_Reuse_Identifier"
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: PingFangBold, size: 14)
        label.textColor = UIColor(hexString: "#18191D")
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private let descLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: PingFang, size: 12)
        label.textColor = UIColor(hexString: "#5A5A67")
        label.textAlignment = .left
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor(hexString: "#F5F6FA")
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descLabel)
        
        iconImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(34)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconImageView.snp.right).offset(12)
            make.right.lessThanOrEqualToSuperview().offset(-20)
            make.top.equalTo(36)
            make.height.equalTo(20)
        }
        
        descLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp_bottom).offset(8)
            make.left.equalTo(titleLabel.snp.left)
            make.right.lessThanOrEqualToSuperview().offset(-20)
            make.bottom.equalTo(iconImageView.snp_bottom).offset(-16)
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        roundedRect(rect: contentView.frame, byRoundingCorners: .allCorners, cornerRadii: CGSize.init(width: 10, height: 10))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainCollectionViewCell {
    
    public func updateModel(_ model: MenuItem) {
        iconImageView.image = UIImage(named: model.imageName)
        titleLabel.text = model.title
        descLabel.text = model.subTitle
    }
    
}
