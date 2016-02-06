//
//  ViewController.swift
//  test
//
//  Created by huchunbo on 16/2/5.
//  Copyright © 2016年 Bijiabo. All rights reserved.
//

import UIKit
import YYText
import CoreGraphics

class ViewController: UIViewController {

    var buttonItem: UIBarButtonItem = UIBarButtonItem()
    var textView: YYTextView!
    var labelDisplayTextView: YYTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1)
        
        title = "Label Control"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        textView = YYTextView()
        
        buttonItem = UIBarButtonItem(title: "Clean", style: UIBarButtonItemStyle.Done, target: self, action: Selector("clean:"))
        
        self.view.backgroundColor = UIColor.whiteColor()
        if self.respondsToSelector("setAutomaticallyAdjustsScrollViewInsets:") {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        let text: NSMutableAttributedString = NSMutableAttributedString(string: "")
        text.yy_font = UIFont.systemFontOfSize(20.0)
        text.yy_lineSpacing = 5
        text.yy_color = UIColor.blackColor()
        
        textView.font = UIFont.systemFontOfSize(20.0)
        textView.attributedText = text
        textView.textParser = YYTextTagBindingParser()
        textView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 200.0)
        textView.backgroundColor = UIColor.whiteColor()
        textView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10)
        textView.delegate = self
        
        textView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.Interactive
        
        textView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        textView.scrollIndicatorInsets = textView.contentInset
        view.addSubview(textView)
        textView.becomeFirstResponder()

        _setupViews()
    }
    
    private func _setupViews() {
        
        labelDisplayTextView = YYTextView()
        labelDisplayTextView.editable = false
        labelDisplayTextView.frame = CGRect(x: 0, y: 200.0, width: view.frame.size.width, height: view.frame.size.height - 200.0)
        labelDisplayTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
        labelDisplayTextView.scrollIndicatorInsets = labelDisplayTextView.contentInset
        view.addSubview(labelDisplayTextView)
        
        let content: String = "Here's to the crazy ones. The misfits. The rebels. The troublemakers. The round pegs in the square holes. The ones who see things differently. They're not fond of rules. And they have no respect for the status quo. You can quote them, disagree with them, glorify or vilify them. About the only thing you can't do is ignore them. Because they change things. They push the human race forward. And while some may see them as the crazy ones, we see genius. Because the people who are crazy enough to think they can change the world, are the ones who do. "
        textView.text = content
    }
    
    func labelsFromString(string: String) -> [String] {
        return string.characters.split(" ").map { (c) -> String in
            return String(c)
        }
    }
    
    func updateLabelsDisplay(labels labels: [String]) {

        let border: YYTextBorder = YYTextBorder()
        border.strokeWidth = 1.5;
        border.strokeColor = UIColor(red:0.36, green:0.5, blue:0.66, alpha:1)
        border.fillColor = UIColor.whiteColor()
        border.cornerRadius = 100; // a huge value
        border.lineJoin = CGLineJoin.Bevel
        
        border.insets = UIEdgeInsetsMake(-5, -8, -5, -8);
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "")
        let spaceString: String = "    "
        
        for (index, value) in labels.enumerate() {
            let attrString: NSMutableAttributedString = NSMutableAttributedString(string: index == 0 ? "" : spaceString)
            attrString.yy_insertString(value, atIndex: index == 0 ? 0 : UInt(spaceString.characters.count))
            attrString.yy_appendString(spaceString)
            attrString.yy_setTextBinding(YYTextBinding(deleteConfirm: false), range: attrString.yy_rangeOfAll())
            attrString.yy_setTextBackgroundBorder(border, range: NSMakeRange(index == 0 ? 0 : spaceString.characters.count, value.characters.count))
            
            attributedString.appendAttributedString(attrString)
        }
        
        attributedString.yy_lineSpacing = 20
        attributedString.yy_color = UIColor(red:0.36, green:0.5, blue:0.66, alpha:1)
        attributedString.yy_font = UIFont.systemFontOfSize(14.0)
        
        labelDisplayTextView.hidden = attributedString.length == 0
        labelDisplayTextView.attributedText = attributedString
    }
    
    func removeAllSubViewsForView(view: UIView) {
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func clean(sender: AnyObject) {
        textView.text = ""
    }
    

}

extension ViewController: YYTextViewDelegate {
    
    override func editButtonItem() -> UIBarButtonItem {
        if textView.isFirstResponder() {
            textView.resignFirstResponder()
        } else {
            textView.becomeFirstResponder()
        }
        
        return buttonItem
    }

    func textViewDidChange(textView: YYTextView) {
        
        if NSString(string: textView.text).length == 0 {
            textView.textColor = UIColor.blackColor()
        }
        
        updateLabelsDisplay(labels: labelsFromString(textView.text))
    }
    
    func textViewDidBeginEditing(textView: YYTextView) {
        
        self.navigationItem.rightBarButtonItem = buttonItem
    }
    
    func textViewDidEndEditing(textView: YYTextView) {
        self.navigationItem.rightBarButtonItem = nil
    }
    
}



@objc class YYTextTagBindingParser: NSObject, YYTextParser {
    
    var regex: NSRegularExpression = NSRegularExpression()
    
    override init() {
        super.init()
        
        let pattern: String = "[^ ]+ "//"[-_a-zA-Z@\\.]+[ ,\\n]"
        do {
            try regex = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
        } catch {
            print(error)
        }
        
    }
    
    func parseText(text: NSMutableAttributedString, selectedRange range: NSRangePointer) -> Bool {
        var changed: Bool = false
        
        regex.enumerateMatchesInString(text.string, options: NSMatchingOptions.WithoutAnchoringBounds, range: text.yy_rangeOfAll()) { (result: NSTextCheckingResult?, flags: NSMatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            guard let result = result else {return}
            
            let range: NSRange = result.range
            if range.length < 1 {
                return
            }
            if text.attribute(YYTextBindingAttributeName, atIndex: range.location, effectiveRange: nil) != nil {
                return
            }
            let bindlingRange: NSRange = NSMakeRange(range.location, range.length-1)
            let binding : YYTextBinding = YYTextBinding(deleteConfirm: true)
            text.yy_setTextBinding(binding, range: bindlingRange)
            text.yy_setFont(UIFont.systemFontOfSize(20.0), range: bindlingRange)
            
            /// Text binding
            text.yy_setColor(UIColor(red: 0.000, green: 0.519, blue: 1.000, alpha: 1.000), range: bindlingRange)
            
            changed = true
            
        }
        
        return changed
    }
    
}

