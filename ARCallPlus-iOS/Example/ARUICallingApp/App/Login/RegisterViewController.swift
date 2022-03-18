//
//  RegisterViewController.swift
//  ARUICallingApp
//
//  Created by 余生丶 on 2022/3/3.
//

import UIKit

class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        let registerView = RegisterRootView()
        registerView.rootVC = self
        view = registerView
    }
    
    func selectUser() {
        let selectVc = SelectHeadController()
        selectVc.modalPresentationStyle = .overFullScreen
        self.present(selectVc, animated: true, completion: nil)
    }
    
    func register(uid: String, name: String, url: String) {
        ProfileManager.shared.register(uid: uid, nickName: name, headUrl: url) {
            AppUtils.shared.showMainController()
        } failed: { error in
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
