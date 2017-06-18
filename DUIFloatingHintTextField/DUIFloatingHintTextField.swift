//
//  DUIFloatingHintTextField.swift
//  DUIFloatingHintTextFieldDemo
//
//  Created by Dhana S on 6/17/17.
//  Copyright © 2017 Dhana S. All rights reserved.
//

import Foundation
import UIKit

public enum TextFieldState{
    case error
    case warning
    case ok
}

public enum FloatingHintTextfieldStyle :  Int{
    case underLine
    case none
}

class DUIFloatingHintTextField: UITextField {
    let TAG_NAME = "DUIFloatingHintTextField_HintMSG"
    let defaultBorderLineColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
    
    let floatLabel = UILabel()
    let messageLabel = MessageLabel()
    let underLineLayer = CALayer()
    static var didmove = 0
    var isFloating : Bool = false
    var errorHint : String!
    var warningHint : String!
    let hintButton = HintButton(type: .custom)
    
    var textfieldState : TextFieldState! = .ok{
        didSet{
            setColor()
        }
    }
    var textFieldStyle : FloatingHintTextfieldStyle! = .underLine
    
    private var floatingPlaceholder : String?{
        didSet{
            floatLabel.text = floatingPlaceholder
            floatLabel.contentMode = .bottom
            floatLabel.numberOfLines = 1
            floatLabel.lineBreakMode = .byTruncatingTail
            floatLabel.sizeToFit()
            if let providedFont = self.font{
                floatLabel.font = providedFont
            }
            if let providedColor = self.textColor{
                let floatingColor = providedColor.withAlphaComponent(0.50)
                floatLabel.textColor = floatingColor
            }
            self.addSubview(floatLabel)
            self.updateFloatLabelBounds()
        }
    }
    
    
    override var bounds: CGRect{
        didSet{
            if self.text!.isEmpty{
                updateFloatLabelBounds()
            }
            underLineLayer.frame = CGRect(x: 0, y: self.bounds.maxY-1, width: self.bounds.maxX, height: 2.0)
        }
    }
    
    override var placeholder: String?{
        didSet{
            if placeholder != nil{
                floatingPlaceholder = placeholder
                placeholder = nil
            }
        }
    }
    
    override var text: String?{
        didSet{
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        selfCustomSetup()
    }
    
    override func layoutSubviews() {
        underLineLayer.frame = CGRect(x: 0, y: self.bounds.maxY-1, width: self.bounds.maxX, height: 2.0)
        super.layoutSubviews()
    }
    
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if self.placeholder != nil{
            let v = self.placeholder!
            self.placeholder = v
        }
        if !self.text!.isEmpty{
            changeFrameForFloatLabel("")
        }
        super.willMove(toSuperview: newSuperview)
    }
    
    override func didMoveToSuperview() {
//        self.perform(#selector(DUIFloatingHintTextField.test), with: nil, afterDelay: 5.0)
        super.didMoveToSuperview()
    }
    
//    func test(){
//        textfieldState = .error
//    }
    
    override func removeFromSuperview() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        super.removeFromSuperview()
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        let returnRect = CGRect(x: rect.origin.x+8, y: 21.0, width: rect.size.width, height: rect.size.height - 21)
        return returnRect
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        let returnRect = CGRect(x: rect.origin.x+8, y: 21.0, width: rect.size.width, height: rect.size.height - 21)
        return returnRect
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        let returnRect = CGRect(x: rect.origin.x+8, y: 21.0, width: rect.size.width, height: rect.size.height - 21)
        return returnRect
    }
    func selfCustomSetup()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(changeFrameForFloatLabel(_:)
            ), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        self.layer.addSublayer(underLineLayer)
        underLineLayer.zPosition = 100
        underLineLayer.backgroundColor = UIColor.darkGray.cgColor
        
        messageLabel.layer.name = TAG_NAME
        messageLabel.borderColor = UIColor.white.cgColor
        messageLabel.fillColor = UIColor.black.withAlphaComponent(0.8).cgColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .justified
        self.clipsToBounds = true
        self.textfieldState = .ok
        setColor()
    }
    
    func updateFloatLabelBounds(){
        floatLabel.sizeToFit()
        let f = self.editingRect(forBounds: self.bounds)
        floatLabel.frame = CGRect(x: f.origin.x, y: f.origin.y, width: floatLabel.frame.size.width, height: f.size.height)
    }
    
    
    func changeFrameForFloatLabel(_ sender : Any ) {
        if self.text == ""{
            isFloating = false
            UIView.animate(withDuration: 0.2) {
                self.floatLabel.transform = CGAffineTransform.identity
                self.updateFloatLabelBounds()
            }
        }else {
            if !isFloating{
                animateFloating()
            }
            isFloating = true
        }
    }
    
    func animateFloating(){
        UIView.animate(withDuration: 0.2) {
            let heightFactor = 21.0 / self.floatLabel.frame.size.height
            let widthToHeightForNew = (self.floatLabel.frame.size.width / self.floatLabel.frame.size.height) * 21
            let widthFactor = widthToHeightForNew / self.floatLabel.frame.size.width
            self.floatLabel.transform = CGAffineTransform(scaleX: widthFactor, y: heightFactor)
            let finalFrame = CGRect(x: 8, y: 0, width: self.floatLabel.frame.size.width, height: self.floatLabel.frame.size.height)
            self.floatLabel.frame = finalFrame
        }
    }
    
    func setColor(){
        switch textfieldState! {
        case .error:
            underLineLayer.backgroundColor = UIColor.red.cgColor
            shake()
            addRightView()
            break
        case .ok:
            underLineLayer.backgroundColor = defaultBorderLineColor
            break
        case .warning:
            underLineLayer.backgroundColor = UIColor.orange.cgColor
            shake()
            addRightView()
            break
        }
    }
    
    func addRightView(){
        errorHint = "jg gfgf f hgfjg jhg ghf gfdgfhgjkgjh fhf gddfgfdfhfjgjgjghf ffg d gfd"
        if (errorHint != nil || warningHint != nil) {
            hintButton.frame = CGRect(origin: .zero, size: CGSize(width: 22.0, height: 22.0))
            hintButton.addTarget(self, action: #selector(DUIFloatingHintTextField.showHint), for: .touchUpInside)
            self.rightViewMode = .always
            self.rightView = hintButton
        }
    }
    
    func shake(){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.1
        animation.autoreverses = true
        animation.repeatCount = 4.0
        animation.fromValue = CGPoint(x: self.center.x - 5.0, y: self.center.y)
        animation.toValue = CGPoint(x: self.center.x + 5.0, y: self.center.y)
        self.layer.add(animation, forKey: "anim")
        if errorHint != nil || warningHint != nil{
            
        }
    }
    
    @objc private func showHint(){
        errorHint = "This is the proposed error message which is going to shown in the top of all views. simple baap of baap"
        var msg:String?
        if let hint = errorHint {
            msg = hint
        }else if let hint = warningHint{
            msg = hint
        }
        if msg == nil{
            return
        }
        messageLabel.text = msg
        messageLabel.textColor = UIColor.white
        let fittableSize = messageLabel.sizeThatFits(CGSize(width: window!.bounds.size.width - 32.0, height: window!.bounds.size.height))
        messageLabel.frame = CGRect(origin: .zero, size: CGSize(width: fittableSize.width+32, height: fittableSize.height+28))
        window?.subviews.first(where: { (view) -> Bool in
            if view.layer.name == self.TAG_NAME{
                print("its there")
                return true
            }
            return false
        })?.removeFromSuperview()
        window?.addSubview(messageLabel)
    }
    
    class MessageLabel: UILabel {
        var borderColor : CGColor!{
            didSet{
                self.layer.borderColor = borderColor
            }
        }
        
        var fillColor : CGColor!{
            didSet{
                self.layer.backgroundColor = fillColor
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.isUserInteractionEnabled = true
        }
        
        convenience init() {
            self.init(frame:.zero)
            self.isUserInteractionEnabled = true
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.isUserInteractionEnabled = true
        }
        
        override func drawText(in rect: CGRect) {
            let r = CGRect(x: 16.0, y: 20.0, width: rect.size.width-32.0, height: rect.size.height - 28)
            super.drawText(in: r)
        }
        
        override func didMoveToSuperview() {
            setUpAutoRemoveListener()
            super.didMoveToSuperview()
            self.perform(#selector(MessageLabel.removeSelf(sender:)), with: self, afterDelay: 5.0)
        }
        
        func setUpAutoRemoveListener(){
            let touchListener = UITapGestureRecognizer(target: self, action: #selector(MessageLabel.removeSelf(sender:)))
            self.addGestureRecognizer(touchListener)
        }
        func removeSelf(sender : Any){
            if let _ = sender as? UITapGestureRecognizer{
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(MessageLabel.removeSelf(sender:)), object: self)
            }
            if let _ = self.superview{
                self.removeFromSuperview()
            }
        }
    }
    
    class HintButton : UIButton{
        
        let aPath1 = UIBezierPath()
        let aPath2 = UIBezierPath()
        
        var textFieldState : TextFieldState!{
            didSet{
                switch textFieldState! {
                case .error:
                    break
                case .ok:
                    break
                case .warning:
                    break
                }
            }
        }
        
        override func draw(_ rect: CGRect) {
            aPath1.move(to: CGPoint(x: (rect.maxX/4.0), y: (rect.maxY/4.0)))
            aPath1.addLine(to: CGPoint(x: rect.maxX-(rect.maxX/4.0), y: rect.maxY-(rect.maxY/4.0)))
            aPath1.lineWidth = 2.0
            UIColor.red.withAlphaComponent(0.8).set()
            aPath1.stroke()
            aPath1.fill()
            aPath2.move(to: CGPoint(x: (rect.maxX/4.0), y: (rect.maxY - rect.maxY/4.0)))
            aPath2.addLine(to: CGPoint(x: rect.maxX-(rect.maxX/4.0), y: (rect.maxY/4.0)))
            aPath2.lineWidth = 2.0
            UIColor.red.withAlphaComponent(0.8).set()
            aPath2.stroke()
            aPath2.fill()
            
            super.draw(rect)
        }
        
        override func willMove(toSuperview newSuperview: UIView?) {
            
            super.willMove(toSuperview: newSuperview)
        }
        
        
        
    }
    
}
