

import UIKit

public protocol BaseTabBarItemView: UIControl {
    var cornerMark: Int { get set }
}

open class DefaultBaseTabbarItemView: UIControl, BaseTabBarItemView {
    
    public var cornerMark: Int = 0 {
        didSet {
            cornerMarkView.isHidden = cornerMark == 0
        }
    }
    
    private var images = [UIControl.State.RawValue : UIImage]()
    private var titles = [UIControl.State.RawValue : String]()
    private var colors = [UIControl.State.RawValue : UIColor]()
    
    public lazy var cornerMarkView: UIView = UIView()

    public lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 4
        stack.addArrangedSubviews(imageView, titleLabel)
        return stack
    }()
    
    public lazy var titleLabel = UILabel(font: .systemFont(ofSize: 12), textColor: .blue, textAlignment: .center)
    
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    public override var isSelected: Bool {
        didSet {
            layoutIfNeeded()
            if oldValue != isSelected {
                updateUI()
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layoutIfNeeded()
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension DefaultBaseTabbarItemView {
    func setImage(_ image: UIImage?, state: UIControl.State) {
        images[state.rawValue] = image
        if state == .normal {
            imageView.image = image
        }
    }
    
    func setTitle(_ title: String, state: UIControl.State) {
        titles[state.rawValue] = title
        if state == .normal {
            titleLabel.text = title
        }
    }
    
    func setTextColor(_ color: UIColor, state: UIControl.State) {
        colors[state.rawValue] = color
        if state == .normal {
            titleLabel.textColor = color
        }
    }
    
    func setFont(_ font: UIFont) {
        titleLabel.font = font
    }
}

extension DefaultBaseTabbarItemView {
    private func setupUI() {
        self.addSubviews(stackView, cornerMarkView)
        NSLayoutConstraint(item: stackView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true

        NSLayoutConstraint(item: cornerMarkView, attribute: .centerY, relatedBy: .equal, toItem: stackView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cornerMarkView, attribute: .right, relatedBy: .equal, toItem: stackView, attribute: .right, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cornerMarkView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: cornerMarkView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 10).isActive = true
    }
    
    private func updateUI() {
        self.imageView.image = self.images[self.state.rawValue] ?? self.images[UIControl.State.normal.rawValue]
        self.titleLabel.text = self.titles[self.state.rawValue] ?? self.titles[UIControl.State.normal.rawValue]
        self.titleLabel.textColor = self.colors[self.state.rawValue] ?? self.colors[UIControl.State.normal.rawValue]
    }
}
