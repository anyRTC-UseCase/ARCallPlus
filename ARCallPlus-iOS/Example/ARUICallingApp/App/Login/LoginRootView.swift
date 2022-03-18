//
//  LoginRootView.swift
//  ARUICallingApp
//
//  Created by 余生丶 on 2022/3/3.
//

import UIKit
import ARUICalling

class LoginRootView: UIView {
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(imageLiteralResourceName: "icon_logo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let phoneLabel: UILabel = {
        let label = UILabel()
        label.text = "手机号"
        label.textColor = UIColor(hexString: "#18191D")
        label.font = UIFont(name: PingFangBold, size: 18)
        return label
    }()
    
    let phoneNumTextField: UITextField = {
       let textField = UITextField()
        textField.backgroundColor = UIColor.white
        textField.textColor = UIColor(hexString: "333333")
        textField.attributedPlaceholder = NSAttributedString(string: "请输入手机号", attributes: [NSAttributedString.Key.font : UIFont(name: PingFangBold, size: 12) ?? UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor(hexString: "#B4B3CE") ?? .gray])
        textField.clearButtonMode = .always
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.addTarget(self, action: #selector(limitPhoneNumber), for: .editingChanged)
        textField.layer.cornerRadius = 4
        textField.layer.masksToBounds = true
        textField.keyboardType = .phonePad
        return textField
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("确定", for: .normal)
        button.addTarget(self, action: #selector(didClickConfirmButton), for: .touchUpInside)
        button.setTitleColor(UIColor(hexString: "#FFFFFF"), for: .normal)
        button.setBackgroundImage(UIColor(hexString: "#294BFF")?.transToImage(), for: .normal)
        button.titleLabel?.font = UIFont(name: PingFang, size: 14)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.isEnabled = false
        return button
    }()
    
    var isViewReady = false
    private var isAgree: Bool = false
    public weak var rootVC: LoginViewController?
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        
        isViewReady = true
        backgroundColor = UIColor(hexString: "#F5F6FA")
        addSubview(logoImageView)
        addSubview(phoneLabel)
        addSubview(phoneNumTextField)
        addSubview(confirmButton)
        
        logoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(convertPixel(h: 110) + kDeviceSafeTopHeight)
            make.width.height.equalTo(150)
            make.centerX.equalToSuperview()
        }
        
        phoneLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp_bottom).offset(42)
            make.leading.equalToSuperview().offset(convertPixel(w:16))
        }
        
        phoneNumTextField.snp.makeConstraints { make in
            make.top.equalTo(phoneLabel.snp_bottom).offset(25)
            make.leading.equalTo(phoneLabel.snp_leading)
            make.trailing.equalToSuperview().offset(-convertPixel(w:16))
            make.height.equalTo(convertPixel(h: 48))
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(phoneNumTextField.snp_bottom).offset(convertPixel(h: 16))
            make.leading.trailing.height.equalTo(phoneNumTextField)
        }
    }
    
    @objc func limitPhoneNumber() {
        let phoneNumber = phoneNumTextField.text
        if phoneNumber?.count ?? 0 > 11 {
            phoneNumTextField.text = String((phoneNumber?.prefix(11))!)
        }
        
        confirmButton.isEnabled = (phoneNumber?.count == 0) ? false : true
    }

    @objc func didClickConfirmButton() {
        guard isPhoneNumber(phoneNumber: phoneNumTextField.text!) else {
            self.makeToast("请输入有效的手机号码", duration: 1.0, position: ARUICSToastPositionCenter)
            return
        }
        
        if isAgree {
            phoneNumTextField.resignFirstResponder()
            rootVC?.login(phone: phoneNumTextField.text!)
        } else {
            popUpAgreement()
        }
    }
    
    func popUpAgreement() {
        ARAlertActionSheet.showAlert(titleStr: "协议条款", msgStr: "ARCallPlus（“本产品”）是由 anyRTC 提供的一款音视频通话产品。请您务必审慎阅读，充分理解各条款内容。除非您已阅读并接受本协议所有条款，否则您无权下载，安装或使用本软件及相关服务。anyRTC享有本产品的著作权和所有权，任何人不得对本产品进行修改、合并、调整、逆向工程、再许可和/或出售该软件的副本以及做出其他损害 anyRTC 合法权益的行为。 若您想试用本产品，欢迎您下载、安装并使用，anyRTC 特此授权您在全球范围内免费使用本产品的权利。本产品按“现状”提供，没有任何形式的明示或暗示担保，包括但不限于对适配性、特定目的的适用性和非侵权性的担保。无论是由于与本产品或本产品的使用或其他方式有关的任何合同、侵权或其他形式的行为，anyRTC 均不对任何索赔、损害或其他责任负责。如果您下载、安装、使用本产品，即表明您确认并同意 anyRTC 对因任何原因在试用本产品时可能对您自身或他人造成的任何形式的损失和伤害不承担任何责任。 若您有任何疑问，请联系 hi@dync.cc.", style: .alert, currentVC: topViewController(), cancelBtn: "暂不使用", cancelHandler: { action in
            
        }, otherBtns: ["同意"]) { index in
            self.isAgree = true
            self.didClickConfirmButton()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
}
