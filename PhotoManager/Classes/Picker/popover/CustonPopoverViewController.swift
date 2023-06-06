//
//  normalImagerPickerOptionsViewController.swift
//  PhotoManager
//
//  Created by Vick on 2023/1/13.
//

import UIKit
import Util_V
import SnapKit

protocol NormalPopoverOption {
    var title: String { get }
}

class NormalPopoverViewController<T: NormalPopoverOption>: UIViewController, UIPopoverPresentationControllerDelegate {
    
    var single: ((_ result: T)->())?
    
    var sort: ((_ ascending: Bool, _ result: T)->())?
    
    private let options: [T]
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 1
        stack.backgroundColor = .black.withAlphaComponent(0.4)
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubviews(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    init(single: [T]) {
        self.options = single
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .popover
        popoverPresentationController?.delegate = self
        popoverPresentationController?.backgroundColor = .white
        preferredContentSize = .init(width: 100, height: options.count*31)
        for index in options.indices {
            let button = UIButton(title: options[index].title, titleColor: .init(photo: "picker_text_color")!, font: .systemFont(ofSize: 16))
            button.tag = index * 10000
            button.backgroundColor = .white
            button.addTarget(self, action: #selector(optionTap), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }
    
    init(sort: [T]) {
        self.options = sort
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .popover
        popoverPresentationController?.delegate = self
        popoverPresentationController?.backgroundColor = .white
        preferredContentSize = .init(width: 150, height: sort.count*31)
        for index in options.indices {
            let button = UIButton(title: sort[index].title, titleColor: .init(photo: "picker_text_color")!, font: .systemFont(ofSize: 16))
            button.tag = index * 10000
            button.backgroundColor = .white
            button.addTarget(self, action: #selector(optionTap), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc private func optionTap(_ sender: UIButton) {
        dismiss(animated: true) {
            let result = self.options[sender.tag / 10000]
            var ascending: Bool
            if (result as? PhotoManager.Sort) == PhotoManager.sharde.sort {
                ascending = !PhotoManager.sharde.ascending
            } else {
                ascending = false
            }
            self.single?(result)
            self.sort?(ascending, result)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}
