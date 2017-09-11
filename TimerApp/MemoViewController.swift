import UIKit
import RealmSwift
import SVProgressHUD

class MemoViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var displayTime: UITextField!
    @IBOutlet weak var displayMemo: UITextView!
    
    
    let realm = try! Realm()
    var memoTask:MemoTask!
    var taskArray = try! Realm().objects(MemoTask.self)
    //    MemoViewControllerでtaskArrayを使うために、Realmからデータをもらい、InputViewControlelrから遷移するときにtaskArrayをもらう
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        displayTime.delegate = self
        displayTime.text = memoTask.displayTime
        displayMemo.text = memoTask.displayMemo
        
        self.displayTime.keyboardType = UIKeyboardType.numberPad
        
    }
    
    
    @IBAction func saveButton(_ sender: UIButton) {
        
//            self.memoTask.displayTime = self.displayTime.text!
//            self.memoTask.displayMemo = self.displayMemo.text
        
        let displayTime = self.displayTime.text!
        let displayMemo = self.displayMemo.text!
        
        if displayTime == "" {
            print("テスト")
            SVProgressHUD.showError(withStatus: "時間を入力して下さい")
            return
        }
        
        for memoTask  in taskArray {
            
            if memoTask.memoId == self.memoTask.memoId {
                continue
            }
            
            if memoTask.displayTime == displayTime {
                print("テスト")
                SVProgressHUD.showError(withStatus: "その時間はすでに登録されています。")
                return
            }
            
        }
        try! realm.write {
            self.memoTask.displayTime = displayTime
            self.memoTask.displayMemo = displayMemo
            self.realm.add(self.memoTask, update: true)
        }
        
        SVProgressHUD.showSuccess(withStatus: "保存しました")
        self.navigationController?.popViewController(animated : true)
    //        一つ前に戻る（rootに戻るとかインデックスを指定して戻るやり方もある）
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    戻るで自動的に保存（チェックなし）
//    override func viewWillDisappear(_ animated: Bool) {
//        try! realm.write {
//            self.memoTask.displayTime = self.displayTime.text!
//            self.memoTask.displayMemo = self.displayMemo.text
//            self.realm.add(self.memoTask, update: true)
//        }
//        
//        super.viewWillDisappear(animated)
//        
//    }
    
    //    アドバンスバーション（前半）
    //    func numberDesuka(s: String) -> Bool {
    //        return Int(s) != nil
    //    }
    
    //  ↓textFieldはdelegateすることで使えるようになるので,displayTime.delegate = selfしておかないと無効
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString str: String) -> Bool {
        return Int(str) != nil || str.isEmpty
        
        
        
        //        自動的にtrueかfalseか判断して答えを吐き出す
        //        ↓これも同じ意味
        //        if Int(str) == nil {
        //            return false
        //        }
        //
        //        return true
        //
        //
        //         アドバンスバーション（後半）
        //        return numberDesuka(s: str)
    }
    
    func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
}

