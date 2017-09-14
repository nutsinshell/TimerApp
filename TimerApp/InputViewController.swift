

import UIKit
import RealmSwift

class InputViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var memoTableView: UITableView!
    
    
    var task: Task!
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
        timeTextField.text = task.time
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
        
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.time = self.timeTextField.text!
            self.realm.add(self.task, update: true)
        }
        
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
        cell.textLabel?.text = (memo.displayTime) + ("min : ")
        
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
        //        let memoViewController:MemoViewController = segue.destination as! MemoViewController
        //
        
        
        if segue.identifier == "cellSegue2" {
            let memoViewController = segue.destination as! MemoViewController
            let indexPath = self.memoTableView.indexPathForSelectedRow
            
            //            memoViewController.taskArray = taskArray
            memoViewController.memoTask = taskArray[indexPath!.row]
            //InputViewからMemoViewに遷移するときにtaskArrayを渡してあげる
        }
        else if segue.identifier == "segueForTimer"{
            let timerViewController = segue.destination as! TimerViewController
            timerViewController.memoTaskArray = taskArray
            timerViewController.titleStr = titleTextField.text!
            timerViewController.timeStr = timeTextField.text!
        }
        else{
            let memoTask = MemoTask()
            memoTask.displayTime = String()
            let allMemos = realm.objects(MemoTask.self)
            if allMemos.count != 0 {
                memoTask.memoId = allMemos.max(ofProperty: "memoId")! + 1
                
            }
            memoTask.taskId = task.id
            let memoViewController = segue.destination as! MemoViewController
            memoViewController.memoTask = memoTask
        }
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        taskArray = try! Realm().objects(MemoTask.self).sorted(byKeyPath: "displayTime", ascending: true).filter("taskId= %ld", task.id)
        memoTableView.reloadData()
    }
    
    
}




