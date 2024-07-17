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
    var phoneBookView: PhoneBookView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        phoneBookView = PhoneBookView(frame: self.view.frame)
        self.view = phoneBookView
        setNavi()
        setAction()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer
        if let model = phoneBookModel{
            notEmptyModel(model: model)
        }
        
    }
    private func setAction(){
        phoneBookView.createImageButton.addTarget(self, action: #selector(createImage), for: .touchDown)
        phoneBookView.deleteButton.addTarget(self, action: #selector(deleteData), for: .touchDown)
    }
    private func setNavi(){
        let button = UIBarButtonItem(title: "적용", style: .plain, target: self, action: #selector(buttonTap))
        navigationItem.title = "연락처 추가"
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItems = [button]
    }
    
    /// ㅡmodel이 있는 경우 UI 추가 구성
    /// - Parameter model: PhoneBookModel
    private func notEmptyModel(model: PhoneBookModel){
        
        phoneBookView.nameTextView.text = model.name
        phoneBookView.numberTextView.text = model.number
        AF.request(model.imageUrl).responseData { response in
            if let data = response.data, let image = UIImage(data: data){
                DispatchQueue.main.async {
                    
                    self.phoneBookView.imageView.image = image
                }
            }
        }
        navigationItem.title = model.name
        navigationItem.largeTitleDisplayMode = .always
        
        [phoneBookView.deleteButton].forEach { view.addSubview($0) }
        
        phoneBookView.deleteButton.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalToSuperview().offset(-20)
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
                    data.setValue(phoneBookView.nameTextView.text, forKey: PhoneBook.Key.name)
                    data.setValue(phoneBookView.numberTextView.text, forKey: PhoneBook.Key.number)
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
        newPhoneBook.setValue(phoneBookView.nameTextView.text, forKey: PhoneBook.Key.name)
        newPhoneBook.setValue(phoneBookView.numberTextView.text, forKey: PhoneBook.Key.number)
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
        if phoneBookView.nameTextView.text.isEmpty{
            isReturn = false
            showAlert(content: "이름 란(이)가 비어있습니다.")
            return
        }
        if urlData.isEmpty && ((phoneBookModel?.imageUrl.isEmpty) == nil){
            isReturn = false
            showAlert(content: "이미지 란(이)가 비어있습니다.")
            return
        }
        if phoneBookView.numberTextView.text.isEmpty{
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
    
    /// 이미지 랜덤으로 생성하는 메서드
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
                                
                                self?.phoneBookView.imageView.image = image
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
