//
//  CallingContactCell.swift
//  ARUICallingApp
//
//  Created by 余生丶 on 2022/3/4.
//

import UIKit

class CallingContactCell: UITableViewCell {
    static let reuseIdentifier = "CallingContactCell_Reuse_Identifier"
    
    private lazy var headImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var namelabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: PingFangBold, size: 14)
        label.textColor = UIColor(hexString: "#5A5A66")
        label.text = "Json"
        return label
    }()
    
    private lazy var phoneLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: PingFang, size: 13)
        label.textColor = UIColor(hexString: "#5A5A66")
        label.text = "13641888888"
        return label
    }()
    
    private lazy var accessoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "icon_unselected")
        return imageView
    }()
    
    var contactModel: LoginModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        accessoryImageView.image = UIImage(named: selected ? "icon_selected" : "icon_unselected")
    }

}

extension CallingContactCell {
    
    func setupUI() {
        accessoryView = accessoryImageView
        contentView.addSubview(headImageView)
        contentView.addSubview(namelabel)
        contentView.addSubview(phoneLabel)
        
        headImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(32)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        namelabel.snp.makeConstraints { make in
            make.top.equalTo(headImageView.snp_top)
            make.leading.equalTo(headImageView.snp_trailing).offset(8)
            make.trailing.equalToSuperview().offset(-100)
        }
        
        phoneLabel.snp.makeConstraints { make in
            make.top.equalTo(namelabel.snp_bottom)
            make.leading.trailing.equalTo(namelabel)
            make.bottom.equalTo(headImageView.snp_bottom)
        }
    }
    
    func updateCell(model: LoginModel) {
        headImageView.sd_setImage(with: NSURL(string: model.headerUrl) as URL?, placeholderImage: UIImage(named: "icon_head"))
        namelabel.text = model.userName
        phoneLabel.text = model.userId
    }
}
