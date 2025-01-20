//
//  PlaceHolderView.swift
//  Tracker
//
//  Created by Nikolay on 18.01.2025.
//

import UIKit

class EmptyView: UIView {

    init(rootView: UIView, parentView: UIView, text: String) {
        super.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(self)
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 1
        self.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        let imageView = UIImageView(image: UIImage(named: "TrackersEmptyScreen"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        self.addSubview(imageView)
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        let label = UILabel()
        let font = UIFont(name: "SF Pro Medium", size: 12) ?? UIFont.systemFont(ofSize: 16)
        let color = UIColor(named: "YPBlack") ?? .black
        let paragraph = NSMutableParagraphStyle()
        paragraph.maximumLineHeight = 18
        paragraph.minimumLineHeight = 18
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : font,
                                                          NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.paragraphStyle: paragraph]
        let attributedTitle = NSAttributedString(string: text, attributes: attributes)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = attributedTitle
        label.textAlignment = .center
        label.numberOfLines = 2
        self.addSubview(label)
        label.widthAnchor.constraint(equalToConstant: 200).isActive = true
        label.heightAnchor.constraint(equalToConstant: 36).isActive = true
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
