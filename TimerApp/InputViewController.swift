

import UIKit
import RealmSwift
import SVProgressHUD

class InputViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var memoTableView: UITableView!
    
    
    var task:Task!
    var memoTask:MemoTask!
    let realm = try! Realm()
    
    
    
    
    
    var taskArray = try! Realm().objects(MemoTask.self).sorted(byKeyPath: "displayTime", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoTableView.delegate = self
        memoTableView.dataSource = self
        memoTableView.keyboardDismissMode = .interactive
        
        
        self.timeTextField.keyboardType = UIKeyboardType.numberPad
        titleTextField.text = task.title
        timeTextField.text = "\(task.time)"
    }
    
    
    func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        taskWrite()
        
        super.viewWillDisappear(animated)
    }
    
    
    
    func taskWrite(){
        //        if (titleTextField.text != nil) || (timeTextField.text != nil)
        
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
        
        if let task = taskArray.last{   //もしlastの値が取れたら
            let displayTime = task.displayTime
            if Int(timeTextField.text!)! < displayTime {
                print("テスト")
                SVProgressHUD.showError(withStatus: "最後のメモより前の時間は登録できません。")
                return
            }
//            取れなかったら比較ができないので遷移に移る
        }
       
        performSegue(withIdentifier: "forTimer",sender: nil)
    
    }
    
    
    
    
    //    ここからメモテーブルのために追加
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ memoTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ memoTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = memoTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let memo = taskArray[indexPath.row]
        cell.detailTextLabel?.text = memo.displayMemo
        cell.textLabel?.text = "\(memo.displayTime)" + "min : "
        
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
                self.realm.delete(self.taskArray[indexPath.row])
                memoTableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "cellSegue2" {
            // edit memo
            
            let memoViewController = segue.destination as! MemoViewController
            let indexPath = self.memoTableView.indexPathForSelectedRow
            
            //            memoViewController.taskArray = taskArray
            memoViewController.memoTask = taskArray[indexPath!.row]
            memoViewController.maxTime = timeTextField.text == "" ? 0 : Int(timeTextField.text!)!
            memoViewController.isNew = false
            //InputViewからMemoViewに遷移するときにtaskArrayを渡してあげる
        }
        else if segue.identifier == "forTimer"{
            let timerViewController = segue.destination as! TimerViewController
            timerViewController.memoTaskArray = taskArray
            timerViewController.titleStr = titleTextField.text!
            timerViewController.timeStr = timeTextField.text!
        }
        else{
            // new memo
            
            let memoTask = MemoTask()
            memoTask.displayTime = Int()
            let allMemos = realm.objects(MemoTask.self)
            memoTask.memoId = allMemos.count + 1
            
            memoTask.taskId = task.id
            
            let memoViewController = segue.destination as! MemoViewController
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
        
        taskArray = try! Realm().objects(MemoTask.self).sorted(byKeyPath: "displayTime", ascending: true).filter("taskId= %ld", task.id)
        memoTableView.reloadData()
    }
    
    
}




