import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_do_list/todo_model.dart';

class TodoService {
  final todoCollection = FirebaseFirestore.instance.collection('todoApp');

  //CREATE
  void addNewTask(TodoModel model) {
    todoCollection.add(model.toMap());
  }

  //UPDATE
  void updateTask(String? docID , bool valueUpdate ) {
    todoCollection.doc(docID).update({
      'isDone' : valueUpdate,
    });
  }

  //DELETE
   void deleteTask(String? docID) {
    todoCollection.doc(docID).delete();
   }

}