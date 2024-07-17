//
//  MainView.swift
//  phoneBook
//
//  Created by 백시훈 on 7/17/24.
//

import Foundation
import UIKit
import SnapKit
class MainView: UIView{
    let tableView = UITableView()
    let button: UIButton = {
        let button = UIButton()
        button.setTitle("추가", for: .normal)
        button.setTitleColor(.orange, for: .normal)
        return button
    }()
    let label: UILabel = {
        let label = UILabel()
        label.text = "친구 목록"
        label.textColor = .black
        label.backgroundColor = .white
        label.font = .boldSystemFont(ofSize: 23)
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func configureUI(){
        
        [button, label, tableView].forEach{ self.addSubview($0) }
        button.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.right.equalTo(self.safeAreaLayoutGuide)
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
        label.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(50)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-10)
        }
    }
}
