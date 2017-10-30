import UIKit
import RealmSwift
import SVProgressHUD

//UIデザインのために追加
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
}

//追加ここまで

class InputViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var memoTableView: UITableView!
    
    
    var task:Task!
//    var memoTask:MemoTask!
    let realm = try! Realm()
    
    var memoTaskArray = try! Realm().objects(MemoTask.self).sorted(byKeyPath: "displayTime", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoTableView.delegate = self
        memoTableView.dataSource = self
        memoTableView.keyboardDismissMode = .interactive
        
        
        timeTextField.delegate = self
        
        self.timeTextField.keyboardType = UIKeyboardType.numberPad
        titleTextField.text = task.title
        timeTextField.text = "\(task.time)"
        
        //        if timeTextField.text == "0"{
        //            timeTextField.textColor = UIColor.red
        //    }
        
        memoTableView.estimatedRowHeight = 30
        memoTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString str: String) -> Bool {
        
        return textField === timeTextField && Int(str) != nil || str.isEmpty
    }   //数字以外のコピペ禁止
    
    
    func taskWrite(){
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.time = Int(self.timeTextField.text!)!
            self.task.updatedAt = NSDate()
            self.realm.add(self.task, update: true)
        }
    }
    
    @IBAction func moveForTimer(_ sender: Any) {
        if timeTextField.text!.isEmpty || Int(timeTextField.text!) == 0  {
            print("テスト")
            SVProgressHUD.showError(withStatus: "所要時間を入力して下さい")
            return
        }
        
        if let task = memoTaskArray.last{   //もしlastの値が取れたら
            let displayTime = task.displayTime
            if Int(timeTextField.text!)! < displayTime {
                print("テスト")
                SVProgressHUD.showError(withStatus: "所要時間が最後のメモより短くなっています。")
                return
            }
            //            取れなかったら比較ができないので遷移に移る
        }
        
        performSegue(withIdentifier: "forTimer",sender: nil)
        
    }
    
    
    @IBAction func moveNewMemo(_ sender: Any) {
        if timeTextField.text!.isEmpty || Int(timeTextField.text!) == 0  {
            print("テスト")
            SVProgressHUD.showError(withStatus: "所要時間を入力して下さい")
            return
        }
        performSegue(withIdentifier: "newMemo",sender: nil)
    }
    
    
    //    ここからメモテーブルのために追加
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ memoTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoTaskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ memoTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = memoTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let memo = memoTaskArray[indexPath.row]
        
       
//        cell.detailTextLabel?.text = memo.displayMemo
        cell.textLabel?.text = "\(memo.displayTime)" + "分目 : " + memo.displayMemo
        
        return cell
    }
    
    
    
    //    セルタップで遷移
    func tableView(_ memoTableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue2",sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ memoTableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ memoTableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            // データベースから削除する  // ←以降追加する
            try! realm.write {               
                self.realm.delete(self.memoTaskArray[indexPath.row])
                
                memoTableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "cellSegue2" {
            // edit memo
            
            let memoViewController = segue.destination as! MemoViewController
            let indexPath = self.memoTableView.indexPathForSelectedRow
            
            //            memoViewController.memoTaskArray = memoTaskArray
            memoViewController.memoTask = memoTaskArray[indexPath!.row]
            memoViewController.maxTime = timeTextField.text == "" ? 0 : Int(timeTextField.text!)!
            memoViewController.isNew = false
            //InputViewからMemoViewに遷移するときにtaskArrayを渡してあげる
        }
        else if segue.identifier == "forTimer"{
            let timerViewController = segue.destination as! TimerViewController
            timerViewController.memoTaskArray = memoTaskArray
            timerViewController.titleStr = titleTextField.text!
            timerViewController.timeStr = Int(timeTextField.text!)!
            timerViewController.taskId = task.id
            //            timerViewController.task = task
        }
        else{
            // new memo
            let memoTask = MemoTask()
            memoTask.displayTime = Int()
            let allMemos = realm.objects(MemoTask.self)
            memoTask.memoId = allMemos.count + 1
            memoTask.taskId = task.id
            
            let naviController = segue.destination as! UINavigationController
            let memoViewController = naviController.viewControllers.first as! MemoViewController
            //            segueでNaviControllerに行って、そのナビのrootvier（firstは最初に紐づけられたという意味）を参照する
            
            memoViewController.memoTask = memoTask
            
            
            //            if (timeTextField.text == "") {
            //                memoViewController.maxTime = 0
            //            } else {
            //                memoViewController.maxTime = Int(timeTextField.text!)!
            //            }
            
            memoViewController.maxTime = timeTextField.text == "" ? 0 : Int(timeTextField.text!)!
            memoViewController.isNew = true
        }
    }
    
    
    
    
    //
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        memoTaskArray = try! Realm().objects(MemoTask.self).sorted(byKeyPath: "displayTime", ascending: true).filter("taskId= %ld", task.id)
        memoTableView.reloadData()
    }
    
    //    override func viewWillDisappear(_ animated: Bool) {
    //        taskWrite()
    //        super.viewWillDisappear(animated)
    //    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !(titleTextField.text!.isEmpty) || Int(timeTextField.text!)! > 0 || memoTaskArray.count > 0 {
            self.taskWrite()
        }
    }
}




