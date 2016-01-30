//
//  BlogTextEditorController.swift
//  BlogTextEditor
//
//  Created by Zhehan Zhang on 2016-01-28.
//  Copyright © 2016 Akhaltech. All rights reserved.
//

import UIKit

class BlogTextEditorController: UIViewController, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var blogTextView: UITextView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    
    let defaultFontSize: CGFloat = 18.0
    var fontSize: CGFloat = 18.0
    var bool: Bool = true
    var isFontColor: Bool = true
    var popoverVC: ColorPickerViewController = ColorPickerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.blogTextView.layer.borderWidth=1  //边框粗细
        self.blogTextView.layer.borderColor=UIColor.grayColor().CGColor
        self.blogTextView.dataDetectorTypes = UIDataDetectorTypes.All
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        if bool {
            keyboardWillChangeFrameWithNotification(notification, showsKeyboard: true)
            bool = !bool
        }
    }
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        if !bool {
            keyboardWillChangeFrameWithNotification(notification, showsKeyboard: false)
            bool = !bool
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillChangeFrameWithNotification(notification: NSNotification, showsKeyboard: Bool) {
        let userInfo = notification.userInfo!
        let animationDuration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        // Convert the keyboard frame from screen to view coordinates.
        let keyboardScreenBeginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let keyboardViewBeginFrame = view.convertRect(keyboardScreenBeginFrame, fromView: view.window)
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        let originDelta = abs((keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y))

        // The text view should be adjusted, update the constant for this constraint.
        if showsKeyboard {
            self.bottomViewConstraint.constant += originDelta
        }else {
            self.bottomViewConstraint.constant -= originDelta
        }
        UIView.animateWithDuration(animationDuration, delay: 0, options: .BeginFromCurrentState, animations: {
            self.bottomView.layoutIfNeeded()
        }, completion: nil)
        
        // Scroll to the selected text once the keyboard frame changes.
        self.blogTextView.scrollRangeToVisible(self.blogTextView.selectedRange)
    }
    
    @IBAction func hideKeyboard(sender: AnyObject) {
        self.blogTextView.resignFirstResponder()
    }
    
    @IBAction func reset(sender: AnyObject) {
        self.fontSize = self.defaultFontSize
        self.blogTextView.typingAttributes[NSFontAttributeName] = UIFont.systemFontOfSize(defaultFontSize)
        self.blogTextView.typingAttributes[NSObliquenessAttributeName] = 0
        self.blogTextView.typingAttributes[NSUnderlineStyleAttributeName] = 0
        self.blogTextView.typingAttributes[NSFontAttributeName] = UIFont.systemFontOfSize(defaultFontSize)
        self.blogTextView.typingAttributes[NSForegroundColorAttributeName] = UIColor.blackColor()
        self.blogTextView.typingAttributes[NSBackgroundColorAttributeName] = UIColor.clearColor()
        Notice.showText("重置样式", fontsize: defaultFontSize, obliqueness: 0)
    }
    
    @IBAction func goBold(sender: AnyObject) {
        let range = self.blogTextView.selectedRange
        if range.length > 0 {
            let changedFontDescriptor = UIFont.systemFontOfSize((self.blogTextView.font?.pointSize)!)
            let typ = self.blogTextView.font
            
            let string = NSMutableAttributedString(attributedString: self.blogTextView.attributedText)
            if typ == changedFontDescriptor {
                let attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize((self.blogTextView.font?.pointSize)!)]
                string.addAttributes(attributes, range: self.blogTextView.selectedRange)
            }else {
                let attributes = [NSFontAttributeName: UIFont.systemFontOfSize((self.blogTextView.font?.pointSize)!)]
                string.addAttributes(attributes, range: self.blogTextView.selectedRange)
            }
            self.blogTextView.attributedText = string
            self.blogTextView.selectedRange = range
        }else {
            let changedFontDescriptor = UIFont.systemFontOfSize((CGFloat)(self.fontSize))
            let typ = self.blogTextView.typingAttributes[NSFontAttributeName] as? UIFont
            if ( typ == changedFontDescriptor) {
                self.blogTextView.typingAttributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize((CGFloat)(self.fontSize))
                Notice.showText("粗体", fontsize: fontSize, obliqueness: 2)
            }else {
                self.blogTextView.typingAttributes[NSFontAttributeName] = UIFont.systemFontOfSize((CGFloat)(self.fontSize))
                Notice.showText("取消粗体", fontsize: fontSize, obliqueness: 2)
            }
        }
    }
    
    @IBAction func goItalic(sender: AnyObject) {
        let range = self.blogTextView.selectedRange
        if range.length > 0 {
            let typ = self.blogTextView.typingAttributes[NSObliquenessAttributeName] as? NSNumber
            
            let string = NSMutableAttributedString(attributedString: self.blogTextView.attributedText)
            if typ == 0.5 {
                let attributes = [NSObliquenessAttributeName: 0.0]
                string.addAttributes(attributes, range: self.blogTextView.selectedRange)
            }else {
                let attributes = [NSObliquenessAttributeName: 0.5]
                string.addAttributes(attributes, range: self.blogTextView.selectedRange)
            }
            self.blogTextView.attributedText = string
            self.blogTextView.selectedRange = range
        }else {
            let typ = self.blogTextView.typingAttributes[NSObliquenessAttributeName] as? NSNumber
            if typ == 0.5 {
                self.blogTextView.typingAttributes[NSObliquenessAttributeName] = 0
                Notice.showText("取消斜体", fontsize: fontSize, obliqueness: 1)
            }else {
                self.blogTextView.typingAttributes[NSObliquenessAttributeName] = 0.5
                Notice.showText("斜体", fontsize: fontSize, obliqueness: 0)
            }
        }
    }

    @IBAction func goUnderline(sender: AnyObject) {
        let range = self.blogTextView.selectedRange
        if range.length > 0 {
            let typ = self.blogTextView.typingAttributes[NSUnderlineStyleAttributeName] as? NSNumber
            
            let string = NSMutableAttributedString(attributedString: self.blogTextView.attributedText)
            if typ == 1 {
                let attributes = [NSUnderlineStyleAttributeName: 0]
                string.addAttributes(attributes, range: self.blogTextView.selectedRange)
            }else {
                let attributes = [NSUnderlineStyleAttributeName: 1]
                string.addAttributes(attributes, range: self.blogTextView.selectedRange)
            }
            self.blogTextView.attributedText = string
            self.blogTextView.selectedRange = range
        }else {
            let typ = self.blogTextView.typingAttributes[NSUnderlineStyleAttributeName] as? NSNumber
            if (typ == 1) {
                self.blogTextView.typingAttributes[NSUnderlineStyleAttributeName] = 0
                Notice.showText("取消下划线", fontsize: fontSize, obliqueness: 0)//弹出提示
            }else {
                self.blogTextView.typingAttributes[NSUnderlineStyleAttributeName] = 1
                Notice.showText("下划线", fontsize: fontSize, obliqueness: 0)//弹出提示
            }
        }
    }

    @IBAction func increaseFontSize(sender: AnyObject) {
        let range = self.blogTextView.selectedRange
        if range.length > 0 {
            if self.blogTextView.font?.pointSize < 36 {
                let string = NSMutableAttributedString(attributedString: self.blogTextView.attributedText)
                var selectedFontSize = self.blogTextView.font!.pointSize
                selectedFontSize += 2
                let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(selectedFontSize)]
                string.addAttributes(attributes, range: self.blogTextView.selectedRange)
                self.blogTextView.attributedText = string
                self.blogTextView.selectedRange = range
            }
        }else {
            if fontSize < 36 {
                self.fontSize = self.blogTextView.font!.pointSize
                fontSize += 2
                self.blogTextView.typingAttributes[NSFontAttributeName] = UIFont.systemFontOfSize((CGFloat)(self.fontSize))
            }
            Notice.showText("增大字体", fontsize: fontSize,obliqueness: 0)//弹出提示
        }
    }
    
    @IBAction func decreaseFontSize(sender: AnyObject) {
        let range = self.blogTextView.selectedRange
        if range.length > 0 {
            if self.blogTextView.font?.pointSize > 8 {
                let string = NSMutableAttributedString(attributedString: self.blogTextView.attributedText)
                var selectedFontSize = self.blogTextView.font!.pointSize
                selectedFontSize -= 2
                let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(selectedFontSize)]
                string.addAttributes(attributes, range: self.blogTextView.selectedRange)
                self.blogTextView.attributedText = string
                self.blogTextView.selectedRange = range
            }
        }else {
            if fontSize > 8 {
                self.fontSize = self.blogTextView.font!.pointSize
                self.fontSize -= 2
                self.blogTextView.typingAttributes[NSFontAttributeName] = UIFont.systemFontOfSize((CGFloat)(self.fontSize))
            }
            Notice.showText("减小字体", fontsize: fontSize,obliqueness: 0) //弹出提示
        }
    }
    
    @IBAction func changeColor(sender: AnyObject) {
        isFontColor = true
        self.popupColorView()
    }
    
    @IBAction func changeBackgroundColor(sender: AnyObject) {
        isFontColor = false
        self.popupColorView()
    }
    
    func popupColorView() {
        popoverVC = storyboard?.instantiateViewControllerWithIdentifier("colorPickerPopover") as! ColorPickerViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(284, 446)
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.sourceView = toolbar
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: 85, height: 30)
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.Any
            popoverController.delegate = self
            popoverVC.delegate = self
        }
        presentViewController(popoverVC, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .None
    }
    
    func setButtonColor (color: UIColor) {
        self.popoverVC.dismissViewControllerAnimated(true, completion: nil)
        
        if isFontColor {
            let range = self.blogTextView.selectedRange
            if range.length > 0 {
                let string = NSMutableAttributedString(attributedString: self.blogTextView.attributedText)
                let attributes = [NSForegroundColorAttributeName: color]
                string.addAttributes(attributes, range: self.blogTextView.selectedRange)
                self.blogTextView.attributedText = string
                self.blogTextView.selectedRange = range
            }else {
                self.blogTextView.typingAttributes[NSForegroundColorAttributeName] = color
            }
        }else {
            let range = self.blogTextView.selectedRange
            if range.length > 0 {
                let string = NSMutableAttributedString(attributedString: self.blogTextView.attributedText)
                let attributes = [NSBackgroundColorAttributeName: color]
                string.addAttributes(attributes, range: self.blogTextView.selectedRange)
                self.blogTextView.attributedText = string
                self.blogTextView.selectedRange = range
            }else {
                self.blogTextView.typingAttributes[NSBackgroundColorAttributeName] = color
            }
        }
    }
    
    @IBAction func insertImage(sender: AnyObject) {
        self.blogTextView.resignFirstResponder()
        var sheet:UIActionSheet
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            sheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil,otherButtonTitles: "从相册选择", "拍照")
        }else{
            sheet = UIActionSheet(title:nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "从相册选择")
        }
        sheet.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        var sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if(buttonIndex != 0){
            if(buttonIndex==1){                                     //相册
                sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.blogTextView.resignFirstResponder()
            }else{
                sourceType = UIImagePickerControllerSourceType.Camera
            }
            let imagePickerController:UIImagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true              //true为拍照、选择完进入图片编辑模式
            imagePickerController.sourceType = sourceType
            self.presentViewController(imagePickerController, animated: true, completion: {
            })
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        let string:NSMutableAttributedString = NSMutableAttributedString(attributedString: self.blogTextView.attributedText)
        var img  = info[UIImagePickerControllerEditedImage] as! UIImage
        img = self.scaleImage(img)
        let textAttachment = NSTextAttachment()
        textAttachment.image = img
        let textAttachmentString = NSAttributedString(attachment: textAttachment)
        
        let countString:Int = self.blogTextView.text.characters.count as Int
        string.insertAttributedString(textAttachmentString, atIndex: countString) //可以用这个函数实现 插入到光标所在点 ps:如果你实现了希望能共享
        self.blogTextView.attributedText = string
        //string.appendAttributedString(textAttachmentString)                    //也可以直接添加都后面
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func scaleImage(image:UIImage)->UIImage{
        UIGraphicsBeginImageContext(CGSizeMake(self.view.bounds.size.width, image.size.height*(self.view.bounds.size.width/image.size.width)))
        image.drawInRect(CGRectMake(0, 0, self.view.bounds.size.width, image.size.height*(self.view.bounds.size.width/image.size.width)))
        let scaledimage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledimage
    }
    
    @IBAction func alignLeft(sender: AnyObject) {
        self.blogTextView.textAlignment = NSTextAlignment.Left
    }
    
    @IBAction func alignCenter(sender: AnyObject) {
        self.blogTextView.textAlignment = NSTextAlignment.Center
    }
    
    @IBAction func alignRight(sender: AnyObject) {
        self.blogTextView.textAlignment = NSTextAlignment.Right
    }
    

}

