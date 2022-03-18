//
//  MainViewController.swift
//  ARUICallingApp
//
//  Created by 余生丶 on 2022/3/3.
//

import UIKit

struct MenuItem {
    var imageName: String
    var title: String
    var subTitle: String?
}

class MainViewController: UIViewController {
    
    let bgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_bg")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        flowLayout.itemSize = CGSize(width: view.bounds.width - 32, height: 120)
        flowLayout.minimumLineSpacing = 16
        flowLayout.minimumInteritemSpacing = 16
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: MainCollectionViewCell.reuseIdentifier)
        return collectionView
    }()
    
    let barButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(title: "anyRTC", style: .done, target: self, action: nil)
        buttonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: PingFangBold, size: 18) as Any, NSAttributedString.Key.foregroundColor: UIColor(hexString: "#18191D") as Any], for: .normal)
        return buttonItem
    }()
    
    lazy var loadingView: DialogAlert = {
        let alert = DialogAlert(frame: UIScreen.main.bounds)
        return alert
    }()
    
    var menus = [
        MenuItem(imageName: "icon_audio", title: "点对点音频通话", subTitle: "全频带音质，打造CD级音频通话盛宴"),
        MenuItem(imageName: "icon_video", title: "点对点视频通话", subTitle: "简单3步即可拥有音视频呼叫通话功能"),
        MenuItem(imageName: "icon_audios", title: "多人语音通话", subTitle: "全频带音质，打造CD级音频通话盛宴"),
        MenuItem(imageName: "icon_videos", title: "多人视频通话", subTitle: "简单3步即可拥有音视频呼叫通话功能")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        loginRtm()
    }
}

extension MainViewController {
    
    func setupUI() {
        addLoading()
        navigationItem.leftBarButtonItem = barButtonItem
        view.addSubview(bgImageView)
        view.addSubview(collectionView)
        
        bgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func loginRtm() {
        
        ProfileManager.shared.loginRTM { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.8) {
                self.loadingView.alpha = 0
            } completion: { result in
                self.loadingView.removeFromSuperview()
            }
            CallingManager.shared.addListener()
            print("Calling - LoginRtm Sucess")
        } failed: { [weak self] error in
            guard let self = self else { return }
            if error == 9 {
                self.loadingView.removeFromSuperview()
                self.refreshLoginState()
            }
            print("Calling - LoginRtm Fail")
        }
    }
    
    func refreshLoginState() {
        ARAlertActionSheet.showAlert(titleStr: "登录超时，请重新登录", msgStr: nil, style: .alert, currentVC: self, cancelBtn: "确定", cancelHandler: { [weak self] action in
            guard let self = self else { return }
            self.addLoading()
            self.loginRtm()
        }, otherBtns: nil, otherHandler: nil)
    }
    
    func addLoading() {
        if let keyWindow = SceneDelegate.getCurrentWindow() {
            keyWindow.addSubview(loadingView)
        }
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menus.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = menus[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCollectionViewCell.reuseIdentifier, for: indexPath) as! MainCollectionViewCell
        cell.updateModel(item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let callingVc = CallingViewController()
        callingVc.callType =  CallingType(rawValue: indexPath.row)
        callingVc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(callingVc, animated: true)
    }
}
