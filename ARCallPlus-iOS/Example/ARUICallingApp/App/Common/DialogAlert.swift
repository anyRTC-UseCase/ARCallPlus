//
//  DialogAlert.swift
//  ARUICallingApp
//
//  Created by 余生 on 2022/3/9.
//

import UIKit

class DialogAlert: UIView {

    private var container: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.9)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()
    
    private var loadImageView: UIImageView = {
        var imageArr: [UIImage] = []
        for index in 0...9 {
            imageArr.append(UIImage(named: String(format: "icon_loading_%d", index))!)
        }
        
        let img = UIImageView(frame: CGRect.zero)
        img.contentMode = .scaleAspectFill
        img.animationImages = imageArr
        img.animationDuration = 1.2
        img.animationRepeatCount = 0
        img.startAnimating()
        return img
    }()
    
    private var loadLabel: UILabel = {
        let label = UILabel()
        label.text = "登录中"
        label.textColor = UIColor(hexString: "#1F47FF")
        label.font = UIFont(name: PingFang, size: 13)
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DialogAlert {
    
    func setupUI() {
        addSubview(container)
        container.addSubview(loadImageView)
        container.addSubview(loadLabel)
        
        container.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-60)
            make.width.height.equalTo(146)
        }
        
        loadImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }
        
        loadLabel.snp.makeConstraints { make in
            make.top.equalTo(loadImageView.snp_bottom).offset(13)
            make.centerX.equalTo(loadImageView.snp_centerX)
        }
    }
}
