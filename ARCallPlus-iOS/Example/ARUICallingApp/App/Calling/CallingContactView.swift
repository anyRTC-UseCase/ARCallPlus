//
//  CallingContactView.swift
//  ARUICallingApp
//
//  Created by 余生丶 on 2022/3/4.
//

import UIKit
import ARUICalling
import AttributedString

class CallingContactView: UIView {

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 71
        tableView.allowsMultipleSelection = true
        tableView.separatorColor = UIColor(hexString: "#DCDCDC")
        tableView.backgroundColor = UIColor.clear
        tableView.register(CallingContactCell.self, forCellReuseIdentifier: CallingContactCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    let searchContainerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = "搜索手机号"
        searchBar.backgroundColor = UIColor(hexString: "#FFFFFF")
        searchBar.barTintColor = UIColor.clear
        searchBar.returnKeyType = .search
        searchBar.keyboardType = .phonePad
        searchBar.layer.cornerRadius = 4
        return searchBar
    }()
    
    private var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("添加", for: .normal)
        button.setBackgroundImage(UIColor(hexString: "#294BFF")?.transToImage(), for: .normal)
        button.titleLabel?.font = UIFont(name: PingFang, size: 14)
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.isEnabled = false
        return button
    }()
    
    private var tagContainerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    private var tagLabel: UILabel = {
        let label = UILabel()
        label.text = "最近联系人"
        label.font = UIFont(name: PingFangBold, size: 16)
        label.textColor = UIColor(hexString: "#1A1A1E")
        return label
    }()
    
    private var lineLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(hexString: "#294BFF")
        return label
    }()
    
    private var numberLabel: UILabel = {
        let label = UILabel()
        label.text = "暂无"
        label.textAlignment = .right
        label.font = UIFont(name: PingFang, size: 14)
        label.textColor = UIColor(hexString: "#B4B4CC")
        return label
    }()
    
    private var placeholderLabel: UILabel = {
        let label = UILabel()
        label.attributed.text = .init("""
        \(.image(#imageLiteral(resourceName: "icon_tag"), .custom(.center, size: .init(width: 16, height: 16)))) \("搜索已注册用户发起通话", .font(UIFont(name: PingFang, size: 14)!), .foreground(UIColor(hexString: "#B4B4CC")!))
        """)
        return label
    }()
    
    private var multi_user = false
    var selectedFinished: (([LoginModel]?, _ isSelected: Bool)->Void)? = nil
    var contactResult: [LoginModel]? =  ProfileManager.shared.getContacts()
    
    public init(frame: CGRect = .zero, type: CallingType, selectHandle: @escaping ([LoginModel]?, _ isSelected: Bool)->Void) {
        super.init(frame: frame)
        backgroundColor = UIColor(hexString: "#F5F6FA")
        selectedFinished = selectHandle
        multi_user = (type == .audios || type == .videos)
        setupUI()
        setupUIStyle()
        updateUIState()
        registerButtonTouchEvents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CallingContactView {
    
    func setupUI() {
        addSubview(tableView)
        addSubview(searchContainerView)
        searchContainerView.addSubview(searchBar)
        searchContainerView.addSubview(addButton)
        addSubview(tagContainerView)
        tagContainerView.addSubview(lineLabel)
        tagContainerView.addSubview(tagLabel)
        tagContainerView.addSubview(numberLabel)
        addSubview(placeholderLabel)
        
        searchContainerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.height.equalTo(40)
        }
        
        addButton.snp.makeConstraints { (make) in
            make.top.trailing.bottom.equalToSuperview()
            make.width.equalTo(84)
        }
        
        searchBar.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(addButton.snp_leading).offset(-10)
        }
        
        tagContainerView.snp.makeConstraints { make in
            make.top.equalTo(searchContainerView.snp_bottom).offset(18)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }
        
        lineLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(16)
        }
        
        tagLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(lineLabel)
            make.leading.equalTo(lineLabel.snp_trailing).offset(8)
        }
        
        numberLabel.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.leading.lessThanOrEqualTo(tagLabel.snp_trailing).offset(20)
        }
        
        placeholderLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(tagContainerView.snp_bottom).offset(24)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
    
    func setupUIStyle() {
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.black
            textfield.backgroundColor = UIColor.clear
            textfield.leftViewMode = .always
            textfield.addTarget(self, action: #selector(limitNumber), for: .editingChanged)
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    func updateUIState() {
        let isExist = (contactResult?.count != 0 && contactResult != nil)
        placeholderLabel.isHidden = isExist
        tableView.isHidden = !isExist
        numberLabel.text = isExist ? "已选择 \(tableView.indexPathsForSelectedRows?.count ?? 0)/\(contactResult!.count)" : "暂无"
    }
    
    @objc func hideKeyboard() {
        endEditing(true)
    }
    
    @objc func limitNumber() {
        addButton.isEnabled = (searchBar.text?.count != 0)
    }
    
    func selectContacts() {
        /// 选择联系人
        updateUIState()
        
        if let finish = selectedFinished {
            guard tableView.indexPathsForSelectedRows != nil else {
                finish(nil, false)
                return
            }
            
            var results: [LoginModel]? = []
            for indexPath in tableView.indexPathsForSelectedRows! {
                let model: LoginModel = contactResult![indexPath.row]
                results?.append(model)
            }
            finish(results, true)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
}

extension CallingContactView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactResult?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CallingContactCell.reuseIdentifier) as! CallingContactCell
        cell.updateCell(model: (contactResult?[indexPath.row])!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !multi_user {
            /// 单人通话单选
            if tableView.indexPathsForSelectedRows?.count ?? 0 > 1 {
                tableView.deselectRow(at: tableView.indexPathsForSelectedRows![0], animated: true)
            }
        } else {
            /// 多人通话最多可选8人
            if tableView.indexPathsForSelectedRows?.count ?? 0 > 8 {
                tableView.deselectRow(at: tableView.indexPathsForSelectedRows![indexPath.row], animated: true)
                self.makeToast("最大选择8人")
            }
        }
        selectContacts()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectContacts()
    }
}

extension CallingContactView {
    
    private func registerButtonTouchEvents() {
        addButton.addTarget(self, action: #selector(searchBtnTouchEvent(sender:)), for: .touchUpInside)
    }
    
    @objc private func searchBtnTouchEvent(sender: UIButton) {
        if let input = self.searchBar.text, input.count > 0 {
            ProfileManager.shared.getUserInfo(uid: input) {[weak self] result in
                guard let self = self else { return }
                if ProfileManager.shared.saveContacts(parameter: [result]) {
                    self.contactResult = ProfileManager.shared.getContacts()
                    self.tableView.reloadData()
                    self.updateUIState()
                } else {
                    self.makeToast("不能添加自己或联系人已添加", duration: 1.5, position: ARUICSToastPositionCenter)
                }
            } failed: { error in
                self.makeToast("联系人不存在", duration: 1.5, position: ARUICSToastPositionCenter)
            }
        }
        
        searchBar.resignFirstResponder()
        addButton.isEnabled = false
        searchBar.text = ""
    }
}
