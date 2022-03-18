//
//  StatementViewController.swift
//  ARUICallingApp
//
//  Created by 余生 on 2022/3/4.
//

import UIKit

class StatementViewController: UIViewController {
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.text = "   本产品是由anyRTC提供的一款体验产品，anyRTC享有本产品的著作权和所有权。特此免费授予获得本产品和相关文档文件（以下简称”软件”）副本的任何人无限制地使用软件的权利，包括但不限制试用，复制，修改，合并，发布，分发，但本产品不得用于商业用途，不得再许可和/或出售该软件的副本。\n\n   本产品按“现状”提供，没有任何形式的明示担保包括但不限于对适配性、特定目的的适用性和非侵权性的担保。无论是由于与本产品或本产品的试用或其他方式有关的任何合同、侵权或其他形式的行为，anyRTC均不对任何索赔、损害或其他责任负责。\n\n   您可以自由选择是否试用本产品提供的服务，如果您下载、安装、试用本产品中所提供的服务，即表明您信任该产品所有人，anyRTC对任何原因在试用本产品中提供的服务时可能对您自身或他人造成的任何形式的损失和伤害不承担任何责任。"
        textView.font = UIFont(name: PingFang, size: 14)
        textView.backgroundColor = UIColor.clear
        return textView
    }()
    
    private lazy var barButtonItem: UIBarButtonItem = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        button.setImage(UIImage(named: "icon_back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        let buttonItem = UIBarButtonItem(customView: button)
        return buttonItem
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hexString: "#F5F6FA")
        navigationItem.leftBarButtonItem = barButtonItem
        navigationItem.title = "免责声明"
        
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        }
    }
    
    @objc func backButtonClick() {
        navigationController?.popViewController(animated: true)
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
