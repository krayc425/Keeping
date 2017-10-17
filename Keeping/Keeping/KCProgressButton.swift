//
//  KCProgressButton.swift
//  KCProgressButton
//
//  Created by 宋 奎熹 on 2017/9/9.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit

class KCProgressButton: UIButton {
    
    /// 下载完成时的 Title
    open var finishDownloadTitle: String = "全部完成"
    
    /// 边框宽度
    open var borderWidth: Float = 0.0 {
        didSet {
            layer.borderWidth = CGFloat(borderWidth)
            layer.borderColor = titleColor(for: .normal)?.cgColor
        }
    }
    
    /// 文字的格式函数
    open var valueFormatter: (_: Float) -> String = {
        return String(format: "%.2f", $0 * 100)
    }
    
    /// 内部作 Mask 的 Label
    private var maskLabel: KCEdgeInsetLabel?
    
    //MARK: - Initializers
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        addMaskLabel(with: (titleLabel?.text ?? ""))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addMaskLabel(with: (titleLabel?.text ?? ""))
    }
    
    override func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(title, for: state)
        addMaskLabel(with: title!)
    }
    
    //MARK: - Set Progress
    
    func setProgress(finished: Int, total: Int) {
        var progress: Float = 0.0
        if total > 0 {
            progress = Float(finished) / Float(total)
        }
        setTitle("\(finished) / \(total)", for: .normal)
        maskLabel?.frame = CGRect(x: 0,
                                  y: 0,
                                  width: CGFloat(progress) * (self.frame.width),
                                  height: self.frame.height)
    }
    
    private func addMaskLabel(with title: String) {
        setNeedsLayout()
        layoutIfNeeded()
        
        self.contentMode = .redraw
        
        if maskLabel != nil {
            maskLabel?.removeFromSuperview()
        }
        
        let titleLabelFrame = titleLabel?.frame
        maskLabel = KCEdgeInsetLabel(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width: 0,
                                                   height: self.frame.height),
                                     edgetInset: UIEdgeInsetsMake(0,
                                                                  (titleLabelFrame?.origin.x)!,
                                                                  0,
                                                                  0))
        maskLabel?.text = title
        maskLabel?.font = titleLabel?.font
        maskLabel?.backgroundColor = titleColor(for: .normal)
        maskLabel?.textColor = backgroundColor
        maskLabel?.lineBreakMode = .byCharWrapping
        maskLabel?.textAlignment = (titleLabel?.textAlignment)!
        maskLabel?.layer.cornerRadius = layer.cornerRadius
        maskLabel?.layer.masksToBounds = true
        maskLabel?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(maskLabel!)
    }
    
    /// 内部作 Mask 的 Label
    class KCEdgeInsetLabel: UILabel {
        
        /// 内部 Label 的内边距
        private var textEdgeInsets: UIEdgeInsets = .zero
        
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        convenience init(frame: CGRect, edgetInset: UIEdgeInsets) {
            self.init(frame: frame)
            textEdgeInsets = edgetInset
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        /// 重载此方法以达到内边距与 Button 的 TitleLabel 内边距相同的目的
        override func drawText(in rect: CGRect) {
            super.drawText(in: UIEdgeInsetsInsetRect(rect, textEdgeInsets))
        }
        
    }
    
}
