//
//  PickerButton.swift
//  PickerButton
//
//  Created by marty-suzuki on 2019/02/18.
//  Copyright © 2019 marty-suzuki. All rights reserved.
//

import UIKit

open class PickerButton: UIButton {

    public private(set) var values: [String] = []
    private let picker = UIPickerView()

    private var delegateProxy: UIPickerViewDelegateProxy?
    public var delegate: UIPickerViewDelegate? {
        set {
            let delegateProxy = UIPickerViewDelegateProxy(newValue)
            delegateProxy.titleChanged = { [weak self] in
                guard let me = self else {
                    return
                }
                me.values[$0.component] = $0.title
                me.updateTitle()
            }
            picker.delegate = delegateProxy
            self.delegateProxy = delegateProxy

            let components = picker.numberOfComponents
            guard components > 0 else {
                return
            }

            self.values = (0..<components).map {
                guard picker.numberOfRows(inComponent: $0) > 0 else {
                    return ""
                }
                return picker.delegate?.pickerView?(picker, titleForRow: 0, forComponent: $0) ?? ""
            }
            updateTitle()
        }
        get {
            return delegateProxy
        }
    }

    public var dataSource: UIPickerViewDataSource? {
        set {
            picker.dataSource = newValue
        }
        get {
            return picker.dataSource
        }
    }

    open var showsSelectionIndicator: Bool {
        set {
            picker.showsSelectionIndicator = newValue
        }
        get {
            return picker.showsSelectionIndicator
        }
    }

    open var closeButtonTitle: String = "Done"

    /// If set true, title is updated automatically when a picker item is selected
    ///
    /// - note: Default is true
    open var shouldUpdateTitleAutomatically = true

    override open var canBecomeFirstResponder: Bool {
        return true
    }

    /// - note: always returns UIPickerView instalce
    override open var inputView: UIView? {
        return picker
    }

    /// - note: always returns UIToolbar instalce that contains close button
    override open var inputAccessoryView: UIView? {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 44)
        let closeButton = UIBarButtonItem(title: closeButtonTitle,
                                          style: .done,
                                          target: self,
                                          action: #selector(PickerButton.didTapClose(_:)))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                    target: nil,
                                    action: nil)
        let items = [space, closeButton]
        toolbar.setItems(items, animated: false)
        toolbar.sizeToFit()

        return toolbar
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        addTarget(self,
                  action: #selector(PickerButton.didTap(_:)),
                  for: .touchUpInside)
    }

    @objc private func didTapClose(_ button: UIBarButtonItem) {
        resignFirstResponder()
    }

    @objc private func didTap(_ button: PickerButton) {
        becomeFirstResponder()
    }

    private func updateTitle() {
        guard shouldUpdateTitleAutomatically else {
            return
        }

        let title = values.reduce(into: "") { result, title in
            if result.isEmpty {
                result += title
            } else {
                result += (" " + title)
            }
        }
        setTitle(title, for: [])
    }
}

// MARK: - UIKeyInput

extension PickerButton: UIKeyInput {

    public var hasText: Bool {
        return !values.isEmpty
    }

    public func insertText(_ text: String) {}

    public func deleteBackward() {}
}
