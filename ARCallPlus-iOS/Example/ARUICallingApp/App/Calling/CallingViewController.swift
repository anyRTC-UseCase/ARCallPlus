//
//  CallingViewController.swift
//  ARUICallingApp
//
//  Created by 余生丶 on 2022/3/4.
//

import UIKit
import ARUICalling

class CallingViewController: UIViewController {
    var callType: CallingType? {
        didSet {
            self.title = callType?.description()
        }
    }
    private var selectedUsers: [LoginModel]?
    private var callingVC = UIViewController()
    
    private lazy var barButtonItem: UIBarButtonItem = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        button.setImage(UIImage(named: "icon_back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        let buttonItem = UIBarButtonItem(customView: button)
        return buttonItem
    }()
    
    private var callingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("发起呼叫", for: .normal)
        button.setBackgroundImage(UIColor(hexString: "#294BFF")?.transToImage(), for: .normal)
        button.titleLabel?.font = UIFont(name: PingFang, size: 14)
        button.addTarget(self, action: #selector(sendCalling), for: .touchUpInside)
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.isEnabled = false
        return button
    }()
    
    lazy var callingContactView: CallingContactView = {
        let callingContactView = CallingContactView(frame: .zero, type: callType!
        ) { [weak self] users, enable in
            guard let `self` = self else {return}
            self.callingButton.isEnabled = enable
            self.selectedUsers = users
        }
        
        return callingContactView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hexString: "#F5F6FA")
        navigationItem.leftBarButtonItem = barButtonItem
        view.addSubview(callingContactView)
        view.addSubview(callingButton)
        
        callingContactView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        callingButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-58)
            make.centerX.equalToSuperview()
            make.width.equalTo(convertPixel(w: 168))
            make.height.equalTo(44)
        }
    }
    
    @objc func sendCalling() {
        CallingManager.shared.callingType = callType!
        let type: ARUICallingType = (callType == .video || callType == .videos) ? .video : .audio
        ARUICalling.shareInstance().call(users: selectedUsers!, type: type)
    }
    
    @objc func backButtonClick() {
        navigationController?.popViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
