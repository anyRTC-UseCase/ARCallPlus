//
//  RegisterRootView.swift
//  ARUICallingApp
//
//  Created by 余生丶 on 2022/3/3.
//

import UIKit
import SDWebImage

class RegisterRootView: UIView {
    
    let headImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 8
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let replaceLabel: UILabel = {
        let label = UILabel()
        label.text = "更换"
        label.font = UIFont(name: PingFang, size: 12)
        label.textAlignment = .center
        label.textColor = UIColor(hexString: "#FFFFFF")
        label.backgroundColor = UIColor(hexString: "#294BFF")
        label.layer.cornerRadius = 8
        label.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        label.layer.masksToBounds = true
        return label
    }()
    
    let nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "昵称"
        label.textColor = UIColor(hexString: "#18191D")
        label.font = UIFont(name: PingFangBold, size: 18)
        return label
    }()
    
    let nickNameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.white
        textField.textColor = UIColor(hexString: "333333")
        textField.attributedPlaceholder = NSAttributedString(string: "请输入昵称", attributes: [NSAttributedString.Key.font : UIFont(name: PingFangBold, size: 12) ?? UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor(hexString: "#B4B3CE") ?? .gray])
        
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        
        let rightView = UIButton(type: .custom)
        rightView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        rightView.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        rightView.setImage(UIImage(named: "icon_dice"), for: .normal)
        rightView.addTarget(self, action: #selector(randomNickName), for: .touchUpInside)
        textField.rightViewMode = .always
        textField.rightView = rightView
        
        textField.addTarget(self, action: #selector(limitNickName), for: .editingChanged)
        textField.layer.cornerRadius = 4
        textField.layer.masksToBounds = true
        textField.keyboardType = .asciiCapable
        return textField
    }()
    
    let completeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("完成", for: .normal)
        button.addTarget(self, action: #selector(didClickCompleteButton), for: .touchUpInside)
        button.setTitleColor(UIColor(hexString: "#FFFFFF"), for: .normal)
        button.setBackgroundImage(UIColor(hexString: "#294BFF")?.transToImage(), for: .normal)
        button.titleLabel?.font = UIFont(name: PingFang, size: 14)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        return button
    }()
    
    var isViewReady = false
    var selectedIndex = Int(arc4random_uniform(30))
    public weak var rootVC: RegisterViewController?
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        
        headImageView.sd_setImage(with: NSURL(string: headUrls[selectedIndex]) as URL?, placeholderImage: UIImage(named: "icon_head"))
        headImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectUserHead)))
        NotificationCenter.default.addObserver(self, selector: #selector(changeUserHead), name: UIResponder.UICallingNotificationSelectedHead, object: nil)
        
        isViewReady = true
        randomNickName()
        backgroundColor = UIColor(hexString: "#F5F6FA")
        addSubview(headImageView)
        addSubview(replaceLabel)
        addSubview(nickNameLabel)
        addSubview(nickNameTextField)
        addSubview(completeButton)
        
        headImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(convertPixel(h: 110) + kDeviceSafeTopHeight)
            make.width.height.equalTo(convertPixel(w: 88))
            make.centerX.equalToSuperview()
        }
        
        replaceLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(headImageView)
            make.height.equalTo(24)
        }
        
        nickNameLabel.snp.makeConstraints { make in
            make.top.equalTo(headImageView.snp_bottom).offset(convertPixel(h:72))
            make.leading.equalToSuperview().offset(convertPixel(w:16))
        }
        
        nickNameTextField.snp.makeConstraints { make in
            make.top.equalTo(nickNameLabel.snp_bottom).offset(25)
            make.leading.equalTo(nickNameLabel.snp_leading)
            make.trailing.equalToSuperview().offset(-convertPixel(w:16))
            make.height.equalTo(convertPixel(h: 48))
        }
        
        completeButton.snp.makeConstraints { make in
            make.top.equalTo(nickNameTextField.snp_bottom).offset(convertPixel(h: 16))
            make.leading.trailing.height.equalTo(nickNameTextField)
        }
    }
    
    @objc func limitNickName() {
        let nickName = nickNameTextField.text
        if nickName?.count ?? 0 > 24 {
            nickNameTextField.text = String((nickName?.prefix(24))!)
        }
        
        completeButton.isEnabled = (nickName?.count == 0) ? false : true
    }
    
    @objc func selectUserHead() {
        rootVC?.selectUser()
    }
    
    @objc func changeUserHead(nofi: Notification) {
        selectedIndex = nofi.userInfo!["index"] as! NSInteger
        headImageView.sd_setImage(with: NSURL(string: headUrls[selectedIndex]) as URL?, placeholderImage: UIImage(named: "icon_head"))
    }
    
    @objc func randomNickName(){
        /// 随机名字
        nickNameTextField.text = randomCharacter(length: 6).lowercased().capitalized
    }
    
    @objc func didClickCompleteButton() {
        rootVC?.register(uid: ProfileManager.shared.localUid!, name: nickNameTextField.text!, url: headUrls[Int(selectedIndex)])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.UICallingNotificationSelectedHead, object: nil)
    }
}
