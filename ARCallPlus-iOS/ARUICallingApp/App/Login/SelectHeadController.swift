//
//  SelectHeadController.swift
//  ARUICallingApp
//
//  Created by 余生 on 2022/3/9.
//

import UIKit

class SelectHeadController: UIViewController, UIGestureRecognizerDelegate {
    
    lazy var containerView: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.white
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var tagLabel: UILabel = {
        let label = UILabel()
        label.text = "设置头像"
        label.font = UIFont(name: PingFangBold, size: 18)
        label.textColor = UIColor(hexString: "#18191D")
        return label
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("确定", for: .normal)
        button.setTitleColor(UIColor(hexString: "#B4B4CE"), for: .normal)
        button.setTitleColor(UIColor(hexString: "#294BFF"), for: .selected)
        button.titleLabel?.font = UIFont(name: PingFangBold, size: 14)
        button.addTarget(self, action: #selector(didClickConfirmButton), for: .touchUpInside)
        return button
    }()
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        flowLayout.itemSize = CGSize(width: 80, height: 80)
        flowLayout.minimumLineSpacing = 6
        flowLayout.minimumInteritemSpacing = 6
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(SelectHeadViewCell.self, forCellWithReuseIdentifier: SelectHeadViewCell.reuseIdentifier)
        return collectionView
    }()
    
    let tap = UITapGestureRecognizer()
    var selectedIndex: NSInteger?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.clear
        tap.delegate = self
        view.addGestureRecognizer(tap)
        setupUI()
    }
    
    func setupUI() {
        view.addSubview(containerView)
        containerView.addSubview(tagLabel)
        containerView.addSubview(confirmButton)
        containerView.addSubview(collectionView)
        
        containerView.snp.makeConstraints { make in
            make.trailing.bottom.leading.equalToSuperview()
            make.height.equalTo(convertPixel(h:524))
        }
        
        tagLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(100)
            make.height.equalTo(20)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.centerX.equalTo(tagLabel.snp_centerX)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(50)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(tagLabel.snp_bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kDeviceSafeBottomHeight)
        }
    }
    
    @objc func didClickConfirmButton(button: UIButton) {
        guard button.isSelected else { return }
        NotificationCenter.default.post(name: UIResponder.UICallingNotificationSelectedHead, object: self, userInfo: ["index": selectedIndex as Any])
        self.dismiss(animated: true, completion: nil)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == view {
            dismiss(animated: true, completion: nil)
            return true
        } else {
            return false
        }
    }
}

extension SelectHeadController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return headUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectHeadViewCell.reuseIdentifier, for: indexPath) as! SelectHeadViewCell
        cell.headImageView.sd_setImage(with: NSURL(string: headUrls[indexPath.row]) as URL?, placeholderImage: UIImage(named: "icon_head"))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: IndexPath(row: indexPath.row, section: 0)) as! SelectHeadViewCell
        cell.isSelected = true
        selectedIndex = indexPath.row
        confirmButton.isSelected = true
    }
}

/// 用户头像
let headUrls: [String] = {
    [
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/1be8f37f883172e2627d130b22f03658.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/471525db8a6ee469036989bb2d9458cc.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/61e7fad153a7c82109de496e5a5a1aeb.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/4a1802f74394e4a957b26dc121aae99e.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/2b09c26bcf7dc36259558e974c4b84db.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/46781d0c51c577f8aca7e30d1c84c906.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/938009652658253930a0897a69a21601.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/439f9305715ba98e8ad5b9f6a1632d21.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/5708fca0acb456a858ec09f326eb71f8.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/b78196cf6b67815ab50b26433eebf4e6.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/f971d600f491aa7f5a3033349c706868.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/0c768308bd376e1254fd66b5c24d0db6.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/2d1a53a1cb9888294f33904fec86a73a.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/6f33e3577cf740c505fbc54af0966605.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/72edb9881cae6721ebb49d43eb0312e8.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/b195f5854851a7dd4a55deee2db7c271.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/1a05d5741cb4d2802190ef9a73624bbc.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/6d80cdd0c7f0cf9876a9e59fda6aa439.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/8bd23da352df7daffffe06f69dec4ba8.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/d00c5df0ab369290b0ea87f7ce5acad9.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/7e18965e9903fb1212c1c04546d4abcc.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/0f61ca1a4423ce46caa2ad16d8e43342.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/761cdd252d67afd69eaece9b5901edfc.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/9c4dca89e0aeb2fdfce04443fc9a935a.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/5aed7263e2effdd365e815a7f6f91417.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/f5f3ff9c1c81e8e25afea070b69bac93.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/0f8518bf057ae4ab7c269847aae86811.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/67ab3f38ea4c685381f13ca597692db6.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/0a97a0a19de5214b42c7478134d35607.jpg",
        "https://anyrtc.oss-cn-shanghai.aliyuncs.com/fbbb28b56158f3d77732d3a2c3a1d1b5.jpg"
    ]
}()
