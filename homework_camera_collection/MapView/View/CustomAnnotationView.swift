//
//  CustomAnnotationView.swift
//  homework_camera_collection
//
//  Created by Эльмира Байгулова on 15.05.2022.
//

import UIKit
import MapKit

class CustomAnnotationView: MKAnnotationView {

    private let boxInset = CGFloat(10)
    private let interItemSpacing = CGFloat(10)
    private let maxContentWidth = CGFloat(90)
    private let contentInsets = UIEdgeInsets(top: 10, left: 30, bottom: 20, right: 20)
    
    private let blurEffect = UIBlurEffect(style: .systemThickMaterial)
    
    private lazy var backgroundMaterial: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [labelVibrancyView, imageView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .top
        stackView.spacing = interItemSpacing
        
        return stackView
    }()
    
    private lazy var labelVibrancyView: UIVisualEffectView = {
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect, style: .secondaryLabel)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        vibrancyView.contentView.addSubview(self.label)
        
        return vibrancyView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.preferredMaxLayoutWidth = maxContentWidth
        
        return label
    }()
        
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: nil)
        return imageView
    }()
    
    private var imageHeightConstraint: NSLayoutConstraint?
    private var labelHeightConstraint: NSLayoutConstraint?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clear
        addSubview(backgroundMaterial)
        
        backgroundMaterial.contentView.addSubview(stackView)
        
        backgroundMaterial.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        backgroundMaterial.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        backgroundMaterial.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backgroundMaterial.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        
        stackView.leadingAnchor.constraint(equalTo: backgroundMaterial.leadingAnchor, constant: contentInsets.left).isActive = true
        stackView.topAnchor.constraint(equalTo: backgroundMaterial.topAnchor, constant: contentInsets.top).isActive = true
        
        imageView.widthAnchor.constraint(equalToConstant: maxContentWidth).isActive = true
        labelVibrancyView.widthAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        labelVibrancyView.heightAnchor.constraint(equalTo: label.heightAnchor).isActive = true
        labelVibrancyView.leadingAnchor.constraint(equalTo: label.leadingAnchor).isActive = true
        labelVibrancyView.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        label.text = nil
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        if let annotation = annotation as? CustomAnnotation {
            label.text = annotation.title
            
            if let image = annotation.image {
                imageView.image = image
                
                if let heightConstraint = imageHeightConstraint {
                    imageView.removeConstraint(heightConstraint)
                }
                
                let ratio = image.size.height / image.size.width
                imageHeightConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: ratio, constant: 0)
                imageHeightConstraint?.isActive = true
            }
        }
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        invalidateIntrinsicContentSize()
        
        
        let contentSize = intrinsicContentSize
        frame.size = intrinsicContentSize
        
        centerOffset = CGPoint(x: contentSize.width / 2, y: contentSize.height / 2)
        
        let shape = CAShapeLayer()
        let path = CGMutablePath()

        let pointShape = UIBezierPath()
        pointShape.move(to: CGPoint(x: boxInset, y: 0))
        pointShape.addLine(to: CGPoint.zero)
        pointShape.addLine(to: CGPoint(x: boxInset, y: boxInset))
        path.addPath(pointShape.cgPath)

        let box = CGRect(x: boxInset, y: 0, width: self.frame.size.width - boxInset, height: self.frame.size.height)
        let roundedRect = UIBezierPath(roundedRect: box,
                                       byRoundingCorners: [.topRight, .bottomLeft, .bottomRight],
                                       cornerRadii: CGSize(width: 5, height: 5))
        path.addPath(roundedRect.cgPath)

        shape.path = path
        backgroundMaterial.layer.mask = shape
    }
    
    override var intrinsicContentSize: CGSize {
        var size = stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        size.width += contentInsets.left + contentInsets.right
        size.height += contentInsets.top + contentInsets.bottom
        return size
    }
}
