//
//  PhoneBookView.swift
//  phoneBook
//
//  Created by 백시훈 on 7/17/24.
//

import Foundation
import UIKit
import SnapKit

class PhoneBookView: UIView{
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 100
        imageView.layer.borderWidth = 2.0
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    let createImageButton: UIButton = {
       let button = UIButton()
        button.setTitle("랜덤 이미지 생성", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    let deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("삭제", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 8
        return button
    }()
    
    let nameTextView: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .left
        textView.font = UIFont.systemFont(ofSize: 16.0)
        textView.text = ""
        textView.textColor = .black
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 2.0
        textView.layer.borderColor = UIColor.systemMint.cgColor
        return textView
    }()
    let numberTextView: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .left
        textView.font = UIFont.systemFont(ofSize: 16.0)
        textView.text = ""
        textView.textColor = .black
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 2.0
        textView.layer.borderColor = UIColor.systemMint.cgColor
        return textView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        configureUI()
    }
    /// 기본 UI 구성
    private func configureUI(){
        
        
        [imageView, createImageButton, nameTextView, numberTextView].forEach {
            self.addSubview($0)
        }
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(50)
            $0.width.equalTo(200)
            $0.height.equalTo(200)
        }
        createImageButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(10)
            $0.width.equalTo(createImageButton.titleLabel!.intrinsicContentSize.width + 20)
            $0.height.equalTo(50)
        }
        nameTextView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(createImageButton.snp.bottom).offset(30)
            $0.height.equalTo(40)
        }
        numberTextView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(nameTextView.snp.bottom).offset(10)
            $0.height.equalTo(40)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
