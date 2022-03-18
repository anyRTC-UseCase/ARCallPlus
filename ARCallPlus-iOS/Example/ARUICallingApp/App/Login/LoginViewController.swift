//
//  LoginViewController.swift
//  ARUICallingApp
//
//  Created by 余生丶 on 2022/3/3.
//

import UIKit
import ARUICalling

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        let loginView = LoginRootView()
        loginView.rootVC = self
        view = loginView
    }
    
    func login(phone: String) {
        ProfileManager.shared.localUid = phone
        ProfileManager.shared.exists(uid: phone) {
            AppUtils.shared.showMainController()
        } failed: {[weak self] result in
            guard let self = self else {return}
            self.showRegisterVC()
        }
    }
    
    func showRegisterVC() {
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
