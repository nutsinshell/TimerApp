//
//  Task.swift
//  
//
//  Created by Mizuki on 2017/08/14.
//
//

import Foundation
import RealmSwift

class Task: Object {
    // 管理用 ID。プライマリーキー
    dynamic var id = 0
    
    // タイトル
    dynamic var title = ""
    
    // 時間
    dynamic var time = ""
    
    // メモ
    dynamic var memo = ""
    
    

    /**
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
//    タスクと紐付けるID
    
    
    // 時間
    dynamic var displayTime = ""
    
    
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

