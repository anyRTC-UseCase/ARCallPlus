//
//  MineViewController.swift
//  ARUICallingApp
//
//  Created by 余生丶 on 2022/3/4.
//

import UIKit

class MineViewController: UITableViewController {
    private let cellIdentifier = "cellIdentifier"
    
    lazy var headView: UIView = {
        let height = ARScreenHeight * 0.138
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ARScreenWidth, height: height))
        view.backgroundColor = UIColor.clear
        
        let loginModel = ProfileManager.shared.localUserModel
        let headImageView = UIImageView(frame: CGRect(x: 15, y: 20, width: 54, height: 54))
        headImageView.layer.cornerRadius = 27
        headImageView.layer.masksToBounds = true
        headImageView.sd_setImage(with: NSURL(string: loginModel!.headerUrl) as URL?, placeholderImage: UIImage(named: "icon_head"))
        view.addSubview(headImageView)
            
        let nameLabel = UILabel(frame: CGRect(x: headImageView.right + 15, y: headImageView.top, width: ARScreenWidth - 140, height: 27))
        nameLabel.text = loginModel?.userName
        nameLabel.font = UIFont(name: PingFangBold, size: 18)
        view.addSubview(nameLabel)
        
        let phoneLabel = UILabel(frame: CGRect(x: nameLabel.left, y: nameLabel.bottom, width: nameLabel.width, height: nameLabel.height))
        phoneLabel.text = "📱 \(loginModel?.userId ?? "")"
        phoneLabel.font = UIFont(name: PingFang, size: 12)
        phoneLabel.textColor = UIColor(hexString: "#5A5A66")
        view.addSubview(phoneLabel)
        
        return view
    }()
    
    let barButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(title: "设置", style: .done, target: self, action: nil)
        buttonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: PingFangBold, size: 18) as Any, NSAttributedString.Key.foregroundColor: UIColor(hexString: "#18191D") as Any], for: .normal)
        return buttonItem
    }()
    
    var menus: [MenuItem] = [
        MenuItem(imageName: "icon_lock", title: "隐私条例"),
        MenuItem(imageName: "icon_log", title: "免责声明"),
        MenuItem(imageName: "icon_register", title: "anyRTC官网"),
        MenuItem(imageName: "icon_time", title: "发版时间", subTitle: "2022.03.10"),
        MenuItem(imageName: "icon_sdkversion", title: "SDK版本", subTitle: String(format: "V %@", "1.0.0")),
        MenuItem(imageName: "icon_appversion", title: "软件版本", subTitle: String(format: "V %@", Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! CVarArg))
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        view.backgroundColor = UIColor(hexString: "#F5F6FA")
        navigationItem.leftBarButtonItem = barButtonItem
        
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = headView
        tableView.tableHeaderView?.height = ARScreenHeight * 0.128
        
        tableView.separatorColor = UIColor(hexString: "#DCDCDC")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menus.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        }
        // Configure the cell...
        cell?.backgroundColor = UIColor.clear
        cell?.selectionStyle = .none
        cell?.textLabel?.text = menus[indexPath.row].title
        cell?.textLabel?.textColor = UIColor(hexString: "#5A5A67")
        cell?.textLabel?.font = UIFont(name: PingFang, size: 14)
        cell?.imageView?.image = UIImage(named: menus[indexPath.row].imageName)
        cell?.detailTextLabel?.textColor = UIColor(hexString: "#C0C0CC")
        cell?.detailTextLabel?.text = menus[indexPath.row].subTitle
        cell?.detailTextLabel?.font = UIFont(name: PingFang, size: 12)
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            UIApplication.shared.open(NSURL(string: "https://anyrtc.io/anyrtc/privacy")! as URL, options: [:], completionHandler: nil)
            
        } else if indexPath.row == 1 {
            let stateVc = StatementViewController()
            stateVc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(stateVc, animated: true)
            
        } else if indexPath.row == 2 {
            UIApplication.shared.open(NSURL(string: "https://www.anyrtc.io")! as URL, options: [:], completionHandler: nil)
        }
    }
}
