//
//  CustomTabelViewCell.swift
//  phoneBook
//
//  Created by 백시훈 on 7/12/24.
//

import Foundation
import SnapKit
import UIKit
class CustomTableViewCell: UITableViewCell{
    
    static let id = "CustomTableViewCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "name"
        label.backgroundColor = .gray
        return label
    }()
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.text = "010-0000-0000"
        label.backgroundColor = .gray
        return label
    }()
    private let customImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 25
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 2.0
        return imageView
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add subviews and setup constraints
        contentView.addSubview(nameLabel)
        contentView.addSubview(numberLabel)
        contentView.addSubview(customImageView)
        
        // Setup constraints using Auto Layout (SnapKit 예제 사용)
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(customImageView.snp.trailing).offset(50)
            $0.centerY.equalToSuperview()
        }
        
        numberLabel.snp.makeConstraints {
            $0.trailing.equalTo(contentView.snp.trailing).offset(-16)
            $0.centerY.equalToSuperview()
        }
        
        customImageView.snp.makeConstraints {
            $0.centerY.equalTo(contentView.snp.centerY)
            $0.trailing.equalTo(contentView.snp.leading).offset(50)
            $0.width.equalTo(50)
            $0.height.equalTo(50)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
