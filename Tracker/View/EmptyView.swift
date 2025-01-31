//
//  PlaceHolderView.swift
//  Tracker
//
//  Created by Nikolay on 18.01.2025.
//

import UIKit

final class EmptyView: UIView {
    
    // MARK: - IB Outlets
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: imageName ?? ""))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        let font = UIFont(name: "SF Pro Medium", size: 12) ?? UIFont.systemFont(ofSize: 12)
        let color = UIColor(named: "YPBlack") ?? .black
        let paragraph = NSMutableParagraphStyle()
        paragraph.maximumLineHeight = 18
        paragraph.minimumLineHeight = 18
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : font,
                                                          NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.paragraphStyle: paragraph]
        let attributedTitle = NSAttributedString(string: text ?? "", attributes: attributes)
        
        label.attributedText = attributedTitle
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    // MARK: - Private Properties
    private var imageName: String?
    private var text: String?

    // MARK: - Initializers
    init(rootView: UIView, parentView: UIView, text: String, imageName: String) {
        super.init(frame: .zero)
        
        self.text = text
        self.imageName = imageName
        translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(self)
        configureUI(parentView: parentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func configureUI(parentView: UIView) {
        
        addSubview(imageView)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            topAnchor.constraint(equalTo: parentView.topAnchor),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
            
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            label.widthAnchor.constraint(equalToConstant: 200),
            label.heightAnchor.constraint(equalToConstant: 36),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8)
        ])
    }
}
