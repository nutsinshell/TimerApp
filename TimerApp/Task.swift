
import Foundation
import RealmSwift

class Task: Object {
    // 管理用 ID。プライマリーキー
    dynamic var id = 0
    
    // タイトル
    dynamic var title = ""
    
    // 時間
    dynamic var time = 0
    
    // メモ
    dynamic var memo = ""
    
    
    dynamic var createdAt = NSDate()    //作成日時
    dynamic var updatedAt = NSDate()    //更新日時
    
    
    
    /*
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}

class MemoTask: Object {
    // 管理用 ID。プライマリーキー
    dynamic var memoId = 0
    
    dynamic var taskId = 0
    // タスクと紐付けるID
    
    
    // 時間
    dynamic var displayTime = 0
    
    
    // メモ
    dynamic var displayMemo = ""
    
    
    
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "memoId"
        
    }
    //
    //    func numberDesuka(s: String) -> Bool {
    //        return Int(s) != nil
    //            }
}

