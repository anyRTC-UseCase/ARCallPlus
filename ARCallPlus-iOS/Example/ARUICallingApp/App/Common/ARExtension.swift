//
//  ARExtension.swift
//  AR-Voice-Tutorial-iOS
//
//  Created by 余生丶 on 2020/9/2.
//  Copyright © 2020 AR. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation

let ARScreenHeight = UIScreen.main.bounds.size.height
let ARScreenWidth = UIScreen.main.bounds.size.width
let PingFang = "PingFang SC"
let PingFangBold = "PingFangSC-Semibold"

extension NSObject {
    
    func toJSONString(dict:NSDictionary?)->String {

        let data = try? JSONSerialization.data(withJSONObject: dict!, options: JSONSerialization.WritingOptions.prettyPrinted)

        let strJson = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)

        return strJson! as String
    }
    
    //RGBA转换
    func RGBA(r:CGFloat,g:CGFloat,b:CGFloat,a: CGFloat) ->UIColor{
        //
        return UIColor(red: r/225.0, green: g/225.0, blue: b/225.0, alpha: a)
    }
    
    func randomCharacter(length : NSInteger) ->String {
        var randomStr = ""
        for _ in 1 ... length{
            let num = 65 + arc4random()%25 //随机6位大写字母
            let randomCharacter = Character(UnicodeScalar(num)!)
            randomStr.append(randomCharacter)
        }
        return randomStr
    }
    
    func generateRandomNumber(num: Int) -> Int{
       var place = 1
       var finalNumber = 0
        
        for _ in 0..<num {
            place *= 10
            let randomNumber = arc4random_uniform(10)
            finalNumber += Int(randomNumber) * place
        }
        return finalNumber
    }
    
    func isPhoneNumber(phoneNumber:String) -> Bool {
        if phoneNumber.count == 0 {
            return false
        }
        let mobile = "^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$"
        let regexMobile = NSPredicate(format: "SELF MATCHES %@",mobile)
        if regexMobile.evaluate(with: phoneNumber) == true {
            return true
        } else {
            return false
        }
    }
    
    func topViewController() -> UIViewController{
        var resultVc: UIViewController
        resultVc = topViewController(vc: UIApplication.shared.keyWindow!.rootViewController!)!
        while ((resultVc.presentedViewController) != nil) {
            resultVc = topViewController(vc: resultVc.presentedViewController!)!
        }
        return resultVc;
    }
    
    func topViewController(vc: UIViewController) -> UIViewController? {
        if vc is UINavigationController {
            let navVc: UINavigationController! = (vc as! UINavigationController)
            return topViewController(vc: navVc.topViewController!)
        } else if (vc is UITabBarController) {
            let tabBarVc: UITabBarController! = (vc as! UITabBarController)
            return topViewController(vc: tabBarVc.selectedViewController!)
        } else {
            return vc
        }
    }
    
    //json转字典
    func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        
        let jsonData:Data = jsonString.data(using: .utf8)!
        
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }
    
    //字典转json
    func getJSONStringFromDictionary(dictionary: NSDictionary) -> String {
        var result:String = ""
           do {
               //如果设置options为JSONSerialization.WritingOptions.prettyPrinted，则打印格式更好阅读
               let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions.init(rawValue: 0))

               if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                   result = JSONString
               }
               
           } catch {
               result = ""
           }
           return result
    }
    
    //JSONString转换为数组
    func getArrayFromJSONString(jsonString:String) ->NSArray{
         
        let jsonData:Data = jsonString.data(using: .utf8)!
         
        let array = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if array != nil {
            return array as! NSArray
        }
        return array as! NSArray
    }
    
    //数组转json
    func getJSONStringFromArray(array:NSArray) -> String {
        if (!JSONSerialization.isValidJSONObject(array)) {
            print("无法解析出JSONString")
            return ""
        }
         
        let data : NSData! = try? JSONSerialization.data(withJSONObject: array, options: []) as NSData?
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
    }
    
    //获取当前时间戳
    func getLocalDateTime() -> String {
        let date = Date()
        let timeFormatter = DateFormatter()
        //"yyy-MM-dd' at 'HH:mm:ss.SSS"
        timeFormatter.dateFormat = "yyy-MM-dd' 'HH:mm"
        let localTime = timeFormatter.string(from: date) as String
        return localTime
    }
    
    func isFullScreen() -> Bool {
        if #available(iOS 11, *) {
              guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
                  return false
              }
              
              if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
                  print(unwrapedWindow.safeAreaInsets)
                  return true
              }
        }
        return false
    }
    
    //富文本
    func getAttributedString(text: String, image: UIImage, index: NSInteger) -> NSMutableAttributedString {
        
        if text.isEmpty {
            return NSMutableAttributedString()
        }
        
        let attri: NSMutableAttributedString = NSMutableAttributedString(string: text)
        let attch: NSTextAttachment = NSTextAttachment()
        attch.image = image
        attch.bounds = CGRect(x: 3, y: -3, width: 15, height: 15)
        
        let attrString: NSAttributedString = NSAttributedString(attachment: attch)
        attri.insert(attrString, at: index)
        return attri
    }
    
    //颜色
    public func changeFontColor(totalString: String, subString: String, font: UIFont, textColor: UIColor)-> NSMutableAttributedString {
        let attStr = NSMutableAttributedString.init(string: totalString)
        attStr.addAttributes([NSAttributedString.Key.foregroundColor: textColor, NSAttributedString.Key.font: font], range: NSRange.init(location: 0, length: subString.count))
        return attStr
    }
    
    //颜色生成图片
    func createImage(_ color: UIColor)-> UIImage{
        let rect = CGRect.init(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    //是否为空
    func isBlank(text: String?) -> Bool {
        if text == nil {
            return true
        }
        return text!.isEmpty
    }
    
    //取值
    func getAttributeValue(text: String?) -> String! {
        if text == nil || isBlank(text: text){
            return ""
        }
        return text
    }
    
    //创建or获取 录音地址
    func creatRecordPath() -> String {
        let manager = FileManager.default
        let baseUrl = NSHomeDirectory() + "/Library/Caches/Record/"
        let exist = manager.fileExists(atPath: baseUrl)
        if !exist {
            do {
                try manager.createDirectory(atPath: baseUrl, withIntermediateDirectories: true, attributes: nil)
                print("Succes to create folder")
            }
            catch {
                print("Error to create folder")
            }
        }
        return baseUrl
    }
    
    // 检测是否为 有线耳机
    func isWiredHeadset() -> Bool {
        let route = AVAudioSession.sharedInstance().currentRoute
        for desc in route.outputs {
            if desc.portType == .headphones {
                return true
            }
        }
        return false
    }
    
    // 判断字符串是否全是空格 true 全是空格
    func stringAllIsEmpty(string: String) -> Bool {
        let trimmedStr = string.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedStr.isEmpty
    }
    
    // 是否为纯数字
    func stringAllIsNumber(string: String) -> Bool {

         let scan: Scanner = Scanner(string: string)

         var val:Int = 0

         return scan.scanInt(&val) && scan.isAtEnd
     }
    
    // 字符串转数组
    func stringToArr(str: String?) -> [Character] {
        if str?.count ?? 0 > 0 {
            var arr = str!.cString(using: .utf8)!
            arr.removeLast()
            return arr.compactMap({Character.init(Unicode.Scalar.init(Int($0))!)})
        }
        return []
    }
    
    // 截屏
    func snapView(targetView: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(targetView.bounds.size, false, 0.0)
        targetView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }
}

var toastLabel: ARMarginLabel?

class ARMarginLabel: UILabel {
    
    var contentInset: UIEdgeInsets = .zero
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect: CGRect = super.textRect(forBounds: bounds.inset(by: contentInset), limitedToNumberOfLines: numberOfLines)
        rect.origin.x -= contentInset.left;
        rect.origin.y -= contentInset.top;
        rect.size.width += contentInset.left + contentInset.right;
        rect.size.height += contentInset.top + contentInset.bottom;
        return rect
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInset))
    }
}

extension UIResponder {
    static let UICallingNotificationSelectedHead = Notification.Name(rawValue: "CallingNotificationSelectedHead")
}

extension CALayer {
    @objc var borderColorFromUIColor: UIColor {
        get {
            return UIColor(cgColor: self.borderColor!)
        } set {
            self.borderColor = newValue.cgColor
        }
    }
}

extension UIView {

    //x position
    var x : CGFloat{
        
        get {
            return frame.origin.x
        }

        set(newVal){
            var tempFrame : CGRect = frame
            tempFrame.origin.x     = newVal
            frame                  = tempFrame
        }
    }


    //y position
    var y : CGFloat{

        get {

            return frame.origin.y

        }


        set(newVal){

            var tempFrame : CGRect = frame
            tempFrame.origin.y     = newVal
            frame                  = tempFrame

        }
    }


    //height
    var height : CGFloat{

        get {

            return frame.size.height

        }

        set(newVal){

            var tmpFrame : CGRect = frame
            tmpFrame.size.height  = newVal
            frame                 = tmpFrame

        }
    }


    // width
    var width : CGFloat {

        get {

            return frame.size.width
        }

        set(newVal) {

            var tmpFrame : CGRect = frame
            tmpFrame.size.width   = newVal
            frame                 = tmpFrame
        }
    }



    // left
    var left : CGFloat {

        get {

            return x
        }

        set(newVal) {

            x = newVal
        }
    }


    // right
    var right : CGFloat {

        get {

            return x + width
        }

        set(newVal) {

            x = newVal - width
        }
    }


    // top
    var top : CGFloat {

        get {

            return y
        }

        set(newVal) {

            y = newVal
        }
    }

    // bottom
    var bottom : CGFloat {

        get {

            return y + height
        }

        set(newVal) {

            y = newVal - height
        }
    }

    //centerX
    var centerX : CGFloat {

        get {

            return center.x
        }

        set(newVal) {

            center = CGPoint(x: newVal, y: center.y)
        }
    }

    //centerY
    var centerY : CGFloat {

        get {

            return center.y
        }

        set(newVal) {

            center = CGPoint(x: center.x, y: newVal)
        }
    }
    //middleX
    var middleX : CGFloat {

        get {

            return width / 2
        }
    }

    //middleY
    var middleY : CGFloat {

        get {

            return height / 2
        }
    }

    //middlePoint
    var middlePoint : CGPoint {

        get {

            return CGPoint(x: middleX, y: middleY)
        }
    }
}

//MARK:- 按钮扩展

enum EdgeInsetsStyle: Int {
    case Top, Left, Bottom, Right
}

extension UIButton {
    //按钮文字图片显示
    func layoutButtonWithEdgeInsetsStyle(style: EdgeInsetsStyle, space: CGFloat) {
        let imageWith: CGFloat = self.imageView!.frame.size.width;
        let imageHeight: CGFloat = self.imageView!.frame.size.height;
        
        var labelWidth: CGFloat = 0.0;
        var labelHeight: CGFloat = 0.0;
        if #available(iOS 8.0, *) {
            // 由于iOS8中titleLabel的size为0，用下面的这种设置
            labelWidth = self.titleLabel!.intrinsicContentSize.width
            labelHeight = self.titleLabel!.intrinsicContentSize.height
        } else {
            labelWidth = self.titleLabel!.frame.size.width
            labelHeight = self.titleLabel!.frame.size.height
        }
        
        var imageEdgeInsets: UIEdgeInsets = UIEdgeInsets.zero;
        var labelEdgeInsets: UIEdgeInsets = UIEdgeInsets.zero;
        
        switch (style) {
        case .Top:
            imageEdgeInsets = UIEdgeInsets(top: -labelHeight-space/2.0, left: 0, bottom: 0, right: -labelWidth)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWith, bottom: -imageHeight-space/2.0, right: 0)
            break
        case .Left:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -space/2.0, bottom: 0, right: space/2.0)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: space/2.0, bottom: 0, right: -space/2.0)
            break
            
        case .Bottom:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -labelHeight-space/2.0, right: -labelWidth)
            labelEdgeInsets = UIEdgeInsets(top: -imageHeight-space/2.0, left: -imageWith, bottom: 0, right: 0)
            break
            
        case .Right:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: labelWidth+space/2.0, bottom: 0, right: -labelWidth-space/2.0)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWith-space/2.0, bottom: 0, right: imageWith+space/2.0)
            break
        }
        
        self.titleEdgeInsets = labelEdgeInsets;
        self.imageEdgeInsets = imageEdgeInsets;
    }
}

private var UIButton_badgeKey : Void?
private var UIButton_badgeBGColorKey : Void?
private var UIButton_badgeTextColorKey : Void?
private var UIButton_badgeFontKey : Void?
private var UIButton_badgePaddingKey : Void?
private var UIButton_badgeMinSizeKey : Void?
private var UIButton_badgeOriginXKey : Void?
private var UIButton_badgeOriginYKey : Void?
private var UIButton_shouldHideBadgeAtZeroKey : Void?
private var UIButton_shouldAnimateBadgeKey : Void?
private var UIButton_badgeValueKey : Void?

extension UIButton {

    // MARK: - 角标
    fileprivate var badgeLabel: UILabel? {
        get {
            return  objc_getAssociatedObject(self, &UIButton_badgeKey) as? UILabel
        }
        set {
            objc_setAssociatedObject(self, &UIButton_badgeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
    }

    // MARK: - 角标
    /**
     * 角标值
     */
    var badgeValue : String?  {
        get{
            return objc_getAssociatedObject(self, &UIButton_badgeValueKey) as? String
        }

        set (badgeValue){
                objc_setAssociatedObject(self, &UIButton_badgeValueKey, badgeValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            if (badgeValue?.isEmpty)!   || (badgeValue == "") || ((badgeValue == "0") && shouldHideBadgeAtZero) {
                    removeBadge()
                } else if (self.badgeLabel == nil ) {
                    self.badgeLabel  = UILabel(frame: CGRect(x: self.badgeOriginX , y: self.badgeOriginY, width: 20, height: 20))
                    self.badgeLabel?.textColor = self.badgeTextColor
                    self.badgeLabel?.backgroundColor = self.badgeBGColor
                    self.badgeLabel?.font = self.badgeFont
                    self.badgeLabel?.textAlignment = .center
                    badgeInit()
                    addSubview(self.badgeLabel!)
                    updateBadgeValue(animated: false)
                } else {
                    updateBadgeValue(animated: true)
                }
        }

    }

    /**
     * Badge background color
     */
    var badgeBGColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &UIButton_badgeBGColorKey) as? UIColor ?? .red
        }
        set {
            objc_setAssociatedObject(self, &UIButton_badgeBGColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if (self.badgeLabel != nil) { refreshBadge() }
        }
    }

    /**
     * Badge text color
     */
    var badgeTextColor: UIColor? {
        get{
            return objc_getAssociatedObject(self, &UIButton_badgeTextColorKey) as? UIColor ?? .white
        }
        set{
            objc_setAssociatedObject(self, &UIButton_badgeTextColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if (self.badgeLabel != nil) {  refreshBadge() }
        }
    }


    /**
     * Badge font
     */
    var badgeFont: UIFont? {
        get {
            return objc_getAssociatedObject(self, &UIButton_badgeFontKey) as? UIFont ?? UIFont.systemFont(ofSize: 10)
        }
        set{
            objc_setAssociatedObject(self, &UIButton_badgeFontKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if (self.badgeLabel != nil) { refreshBadge() }
        }
    }

    /**
     *  Padding value for the badge
     */
    var badgePadding: CGFloat {
        get{
            return  objc_getAssociatedObject(self, &UIButton_badgePaddingKey) as? CGFloat ?? 6
        }
        set{
            objc_setAssociatedObject(self, &UIButton_badgePaddingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if (self.badgeLabel != nil) { updateBadgeFrame() }
        }
    }

    /**
     * badgeLabel 最小尺寸
     */
    var badgeMinSize: CGFloat {
        get{
            return objc_getAssociatedObject(self, &UIButton_badgeMinSizeKey) as? CGFloat ?? 8
        }
        set{
            objc_setAssociatedObject(self, &UIButton_badgeMinSizeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if (self.badgeLabel != nil) { updateBadgeFrame() }
        }
    }

    /**
     *  badgeLabel OriginX
     */
    var badgeOriginX: CGFloat {
        get{
            return objc_getAssociatedObject(self, &UIButton_badgeOriginXKey) as? CGFloat ?? 0
        }
        set{
            objc_setAssociatedObject(self, &UIButton_badgeOriginXKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if (self.badgeLabel != nil) {
                updateBadgeFrame()
            }
        }
    }

    /**
     * badgeLabel OriginY
     */
    var badgeOriginY: CGFloat  {
        get{
            return objc_getAssociatedObject(self, &UIButton_badgeOriginYKey) as? CGFloat ?? -6
        }
        set{
            objc_setAssociatedObject(self, &UIButton_badgeOriginYKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if (self.badgeLabel != nil) {
                updateBadgeFrame()
            }
        }
    }

    /**
     * In case of numbers, remove the badge when reaching zero
     */
    var shouldHideBadgeAtZero: Bool  {
        get {
            return objc_getAssociatedObject(self, &UIButton_shouldHideBadgeAtZeroKey) as? Bool ?? true
        }
        set {
            objc_setAssociatedObject(self, &UIButton_shouldHideBadgeAtZeroKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
     * Badge has a bounce animation when value changes
     */
    var shouldAnimateBadge: Bool {
        get{
            return objc_getAssociatedObject(self, &UIButton_shouldAnimateBadgeKey) as? Bool ?? true
        }
        set{
            objc_setAssociatedObject(self, &UIButton_shouldAnimateBadgeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    
    fileprivate func badgeInit()  {
        if let label = self.badgeLabel {
            self.badgeOriginX = self.frame.size.width - label.frame.size.width/2
        }
        
        self.clipsToBounds = false
    }

    fileprivate func refreshBadge() {
        guard let tempLabel = self.badgeLabel else { return }
        tempLabel.textColor = self.badgeTextColor
        tempLabel.backgroundColor  = self.badgeBGColor
        tempLabel.font  = self.badgeFont
    }

    fileprivate func removeBadge() {
        UIView.animate(withDuration: 0.2, animations: {
            self.badgeLabel?.transform = CGAffineTransform.init(scaleX: 0, y: 0)
        }) { (finished: Bool) in
            self.badgeLabel?.removeFromSuperview()
            if (self.badgeLabel != nil) { self.badgeLabel = nil }
        }
    }



    fileprivate func updateBadgeValue(animated: Bool) {
        if animated && self.shouldAnimateBadge && !(self.badgeLabel?.text == self.badgeValue) {
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.fromValue = 1.5
            animation.toValue = 1
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 1.3, 1.0, 1.0)
            self.badgeLabel?.layer.add(animation, forKey: "bounceAnimation")
        }

        var badgeValue = 0
        if let badgeStr = self.badgeValue , let value = Int(badgeStr) {
                badgeValue = value
        }
        self.badgeLabel?.text = badgeValue >= 99 ? "99+" : self.badgeValue
        self.badgeLabel?.text =  self.badgeValue
        let duration: TimeInterval = (animated && self.shouldAnimateBadge) ? 0.2 : 0
        UIView.animate(withDuration: duration, animations: {
            self.updateBadgeFrame()
        })
    }

    fileprivate  func updateBadgeFrame() {
        let expectedLabelSize: CGSize = badgeExpectedSize()
        var minHeight: CGFloat = expectedLabelSize.height
        minHeight = (minHeight < badgeMinSize) ? badgeMinSize : expectedLabelSize.height
    
        var minWidth: CGFloat = expectedLabelSize.width
        let padding = self.badgePadding
        minWidth = (minWidth < minHeight) ? minHeight : expectedLabelSize.width
        
        
        let badgeWidth = minWidth + padding
        let badgeHeight = minHeight + padding

        if self.badgeOriginX > self.frame.size.width {
            self.badgeOriginX = self.frame.size.width - badgeWidth/2
        }
        
        if self.badgeOriginY > self.frame.size.height {
            self.badgeOriginY = self.frame.size.height - badgeHeight/2
        }

        self.badgeLabel?.frame = CGRect(x: self.badgeOriginX - 3, y: self.badgeOriginY + 8, width: badgeWidth, height: badgeHeight)
        self.badgeLabel?.layer.cornerRadius = badgeHeight / 2
        self.badgeLabel?.layer.masksToBounds = true
    }

    fileprivate func badgeExpectedSize() -> CGSize {
        let frameLabel: UILabel = duplicate(self.badgeLabel)
        frameLabel.sizeToFit()
        let expectedLabelSize: CGSize = frameLabel.frame.size
        return expectedLabelSize
    }

    fileprivate func duplicate(_ labelToCopy: UILabel? ) -> UILabel {
        guard let temp = labelToCopy else { fatalError("xxxx") }
        let duplicateLabel = UILabel(frame: temp.frame )
        duplicateLabel.text = temp.text
        duplicateLabel.font = temp.font
        return duplicateLabel
    }
}

extension UIColor {
    convenience init?(hexString: String) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        let length = hexSanitized.count
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    class var randomColor: UIColor {
        get {
            let red = CGFloat(arc4random()%256)/255.0
            let green = CGFloat(arc4random()%256)/255.0
            let blue = CGFloat(arc4random()%256)/255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
    
    // 颜色转化为图片
    public func transToImage() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(self.cgColor)
        context?.fill(rect)
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return theImage ?? UIImage()
    }
}

extension UIImage {
    class func imageWithColor(_ color: UIColor) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

extension UITextField {
   @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}

extension UserDefaults {
    enum AccountKeys: String {
        case uid
        case userToken
        case userName
        case appid
        case avatar
        case isLogin
    }
    
    static func set(value: String, forKey key: AccountKeys) {
        let key = key.rawValue
        UserDefaults.standard.set(value, forKey: key)
    }

    static func string(forKey key: AccountKeys) -> String? {
        let key = key.rawValue
        return UserDefaults.standard.string(forKey: key)
    }
}

extension Array where Element: Equatable {
    
    mutating func remove(_ object: Element) {
        if let index = firstIndex(of: object) {
            remove(at: index)
        }
    }
}

extension UIViewController {
    
    func createBarButtonItem(title: String?, image: String?) -> UIBarButtonItem {
        let leftButton = UIButton.init(type: .custom)
        leftButton.addTarget(self, action: #selector(popBack), for: .touchUpInside)
        leftButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 10, bottom: 5, right: 10)
        if image?.count != 0 {
            leftButton.setImage(UIImage(named: image!), for: .normal)
        }
        
        if (title?.count != 0) {
            leftButton.setTitle(title, for: .normal)
            leftButton.setTitleColor(UIColor(hexString: "#1A1A1E"), for: .normal)
            leftButton.titleLabel?.font = UIFont(name: PingFangBold, size: 14)
            leftButton.layoutButtonWithEdgeInsetsStyle(style: .Left, space: 0)
        }
        return UIBarButtonItem(customView: leftButton)
    }
    
    @objc func popBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

class ARAlertActionSheet {
    static func showAlert(titleStr: String?, msgStr: String?, style: UIAlertController.Style = .alert, currentVC: UIViewController, cancelBtn: String = "取消", cancelHandler:((UIAlertAction) -> Void)?, otherBtns:Array<String>?, otherHandler:((Int) -> ())?) {
        
        DispatchQueue.main.async {
            let alertVc = UIAlertController(title: titleStr, message: msgStr,preferredStyle: style)
            
            let cancelAction = UIAlertAction(title:cancelBtn, style: .cancel, handler:{ (action) -> Void in
                cancelHandler?(action)
            })
            cancelAction.setValue(UIColor(hexString: "#1F47FF"), forKey: "titleTextColor")
            alertVc.addAction(cancelAction)
            
            if otherBtns != nil {
                for (index, value) in (otherBtns?.enumerated())! {
                    let otherAction = UIAlertAction(title: value, style: .default, handler: { (action) in
                        otherHandler!(index)
                    })
                    otherAction.setValue(UIColor(hexString: "#181914"), forKey: "titleTextColor")
                    alertVc.addAction(otherAction)
                }
            }
             currentVC.present(alertVc, animated: true, completion: nil)
        }
    }
}

public let kDeviceIsIphoneX : Bool = {
    if UIDevice.current.userInterfaceIdiom == .pad {
        return false
    }
    let size = UIScreen.main.bounds.size
    let notchValue = Int(size.width/size.height*100)
    if notchValue == 216 || notchValue == 46 {
        return true
    }
    return false
}()

public let kDeviceSafeTopHeight : CGFloat = {
    if kDeviceIsIphoneX {
        return 44
    }
    else {
        return 20
    }
}()

public let kDeviceSafeBottomHeight : CGFloat = {
    if kDeviceIsIphoneX {
        return 34
    }
    else {
        return 0
    }
}()

public func convertPixel(w:CGFloat) -> CGFloat {
    return w/375.0 * ARScreenWidth
}

public func convertPixel(h:CGFloat) -> CGFloat {
    return h/812.0 * ARScreenHeight
}

public extension UIView {
    /// 切部分圆角
    ///
    /// - Parameters:
    ///   - rect: 传入View的Rect
    ///   - byRoundingCorners: 裁剪位置
    ///   - cornerRadii: 裁剪半径
    func roundedRect(rect:CGRect, byRoundingCorners: UIRectCorner, cornerRadii: CGSize) {
        let maskPath = UIBezierPath.init(roundedRect: rect, byRoundingCorners: byRoundingCorners, cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    /// 切圆角
    ///
    /// - Parameter rect: 传入view的Rect
    func roundedCircle(rect: CGRect) {
        roundedRect(rect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: bounds.size.width / 2, height: bounds.size.height / 2))
    }
}


