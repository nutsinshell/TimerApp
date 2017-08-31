import UIKit
import RealmSwift

class MemoViewController: UIViewController {
    
    
    @IBOutlet weak var displayTime: UITextField!
    @IBOutlet weak var displayMemo: UITextView!
    
    
    let realm = try! Realm()
    var memoTask:MemoTask!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        displayTime.text = memoTask.displayTime
        displayMemo.text = memoTask.displayMemo
        
        self.displayTime.keyboardType = UIKeyboardType.numberPad
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.memoTask.displayTime = self.displayTime.text!
            self.memoTask.displayMemo = self.displayMemo.text
            self.realm.add(self.memoTask, update: true)
        }
        
        super.viewWillDisappear(animated)
    }
    
    func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
   
}
