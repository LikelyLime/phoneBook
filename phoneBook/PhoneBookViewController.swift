//
//  PhoneBookViewController.swift
//  phoneBook
//
//  Created by 백시훈 on 7/12/24.
//

import Foundation
import UIKit
import SnapKit
import Alamofire
import CoreData

class PhoneBookViewController: UIViewController{
    var phoneBookModel: PhoneBookModel?
    var urlData = ""
    var container: NSPersistentContainer!
    var isCell = false
    var isReturn = false
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 100
        imageView.layer.borderWidth = 2.0
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private let createImageButton: UIButton = {
       let button = UIButton()
        button.setTitle("랜덤 이미지 생성", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(createImage), for: .touchDown)
        return button
    }()
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("삭제", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(deleteData), for: .touchDown)
        return button
    }()
    
    private let nameTextView: UITextView = {
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
    private let numberTextView: UITextView = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer
        if let model = phoneBookModel{
            notEmptyModel(model: model)
        }
        
    }
    
    
    /// ㅡmodel이 있는 경우 UI 추가 구성
    /// - Parameter model: PhoneBookModel
    private func notEmptyModel(model: PhoneBookModel){
        
        nameTextView.text = model.name
        numberTextView.text = model.number
        AF.request(model.imageUrl).responseData { response in
            if let data = response.data, let image = UIImage(data: data){
                DispatchQueue.main.async {
                    
                    self.imageView.image = image
                }
            }
        }
        navigationItem.title = model.name
        navigationItem.largeTitleDisplayMode = .always
        
        [deleteButton].forEach { view.addSubview($0) }
        
        deleteButton.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
    
    
    
    /// 기본 UI 구성
    private func configureUI(){
        let button = UIBarButtonItem(title: "적용", style: .plain, target: self, action: #selector(buttonTap))
        navigationItem.title = "연락처 추가"
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItems = [button]
        [imageView, createImageButton, nameTextView, numberTextView].forEach {
            view.addSubview($0)
        }
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(50)
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
    
    /// 적용버튼 클릭시 이벤트
    @objc func buttonTap(){
        validData()
        if isCell {
            updateData()
        }else{
            createData()
        }
        returnPage()
    }
    
    @objc func deleteData(){
        let fetchRequest = PhoneBook.fetchRequest()
        if let model = phoneBookModel{
            fetchRequest.predicate = NSPredicate(format: "name == %@", model.name)
            do{
                let result = try self.container.viewContext.fetch(fetchRequest)
                for data in result as [NSManagedObject]{
                    self.container.viewContext.delete(data)
                }
                try self.container.viewContext.save()
                isReturn = true
                showAlert(content: "정상적으로 처리되었습니다.")
                
            }catch{
                showAlert(content: "작업에 실패하였습니다.")
            }
        }
    }
    /// 데이터 업데이트
    private func updateData(){
        let fetchRequest = PhoneBook.fetchRequest()
        if let model = phoneBookModel{
            fetchRequest.predicate = NSPredicate(format: "name == %@", model.name)
            do{
                let result = try self.container.viewContext.fetch(fetchRequest)
                for data in result as [NSManagedObject]{
                    data.setValue(nameTextView.text, forKey: PhoneBook.Key.name)
                    data.setValue(numberTextView.text, forKey: PhoneBook.Key.number)
                    if let imageUrl = URL(string: urlData) {
                        data.setValue(imageUrl as NSURL, forKey: PhoneBook.Key.imageUrl)
                    }
                }
            }catch{
                showAlert(content: "작업에 실패하였습니다.")
            }
        }
        
        
    }
    
    /// 데이터 coreData에 저장하는 메서드
    public func createData(){
        guard let entity = NSEntityDescription.entity(forEntityName: PhoneBook.className, in: self.container.viewContext) else { return }
        let newPhoneBook = NSManagedObject(entity: entity, insertInto: self.container.viewContext)
        newPhoneBook.setValue(nameTextView.text, forKey: PhoneBook.Key.name)
        newPhoneBook.setValue(numberTextView.text, forKey: PhoneBook.Key.number)
        if let imageUrl = URL(string: urlData) {
            newPhoneBook.setValue(imageUrl as NSURL, forKey: PhoneBook.Key.imageUrl)
        }
        do{
            try self.container.viewContext.save()
        }catch{
            showAlert(content: "작업에 실패하였습니다.")
        }
    }
    
    /// 이전 페이지로 돌아가는 메서드
    private func returnPage(){
        navigationController?.popViewController(animated: true)
    }
    
    /// 유효성 검사하는 메서드
    private func validData(){
        if nameTextView.text.isEmpty{
            isReturn = false
            showAlert(content: "이름 란(이)가 비어있습니다.")
            return
        }
        if urlData.isEmpty{
            isReturn = false
            showAlert(content: "이미지 란(이)가 비어있습니다.")
            return
        }
        if numberTextView.text.isEmpty{
            isReturn = false
            showAlert(content: "전화번호 란(이)가 비어있습니다.")
            return
        }
    }
    
    
    /// alert창 띄워주는 메서드
    /// - Parameter content: 멘트
    private func showAlert(content: String){
        let alert = UIAlertController(title: "확인", message: "\(content)", preferredStyle: .alert)
        if isReturn {
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.returnPage()
            }))
        }else{
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
        present(alert, animated: true, completion: nil)
        returnPage()
    }
    
    /// 이미지 핸덤으로 생성하는 메서드
    @objc func createImage(){
        let randomNum = Int.random(in: 1...1000)
        let urlComponents = URLComponents(string: "https://pokeapi.co/api/v2/pokemon/\(randomNum)")
        guard let url = urlComponents?.url else {
            print("잘못된 URL 입니다.")
            return
        }
        fetchDataByAlamofire(url: url){ [weak self] (result: Result<NewImageResponse, AFError>) in
            switch result {
                case .success(let result):
                    guard let imageUrl = URL(string: result.sprites.frontDefault)else{
                        return
                    }
                    self!.urlData = String(result.sprites.frontDefault)
                    AF.request(imageUrl).responseData { response in
                        if let data = response.data, let image = UIImage(data: data){
                            DispatchQueue.main.async {
                                
                                self?.imageView.image = image
                            }
                        }
                    }
                case .failure(let error):
                    print("데이터 로드 실패: \(error)")
                    
            }
        }
    }
    
    /// API 호출하는 메서드
    /// - Parameters:
    ///   - url: URL
    ///   - completion: 결과Model
    private func fetchDataByAlamofire<T: Decodable>(url: URL, completion: @escaping (Result<T, AFError>) -> Void) {
        AF.request(url).responseDecodable(of: T.self) { response in
            completion(response.result)
        }
    }
    
}
