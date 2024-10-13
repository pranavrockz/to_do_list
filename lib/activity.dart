import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list/AuthFunc.dart';
import 'package:to_do_list/service_provider.dart';
import 'package:to_do_list/show_modle.dart';

import 'card_to_do_list.dart';

class Activity extends ConsumerWidget {
  const Activity({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context , WidgetRef ref)
  {
    DateTime now = DateTime.now(); // Get current date and time
    String formattedDate = DateFormat('EEEE, d MMMM').format(now); // Format it
    final todoData = ref.watch(fetchStreamProvider);
    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        title: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.amber.shade300,
            radius: 25,
            child: Image.asset("assets/profile.png"),
          ),
          title: Text(
              'Hello I\'m',
              style : TextStyle(fontSize: 12, color : Colors.grey.shade400)
          ),
          subtitle: const Text(
              'Pranav Bhatnagar',
               style : TextStyle(fontWeight: FontWeight.bold , color : Colors.black),
          ),
        ),
        actions: [
          Padding(padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.calendar),
              ),

              IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.bell)),
            ]),
          )
        ],  
    ),

    body: SingleChildScrollView(
      child: Padding(padding: const EdgeInsets.symmetric(
        horizontal: 30), child: Column(
        children: [
          const Gap(20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Today\'s Task' ,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color : Colors.black
                ),),

                Text(formattedDate ,
                style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            ElevatedButton(onPressed: () => showModalBottomSheet(
                isScrollControlled: true,
                shape : RoundedRectangleBorder( borderRadius: BorderRadius.circular(16)),
                context: context,
                builder: (context) => AddNewTaskModel(),
                ),
            style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD5E8FA),
                  foregroundColor: Colors.blue.shade800,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                  )
                ),
                child: const Text('+ New Task' ,
                style : TextStyle(color : Colors.grey),
                ),
            ),

          ],
          ),
          //Card list item
          const Gap(20),
          ListView.builder(
            itemCount: todoData.value!.length ?? 0,
            shrinkWrap: true,
            itemBuilder: (context , index) => CardTodoListWidget(getIndex: index,),
          )
        ],
      ),
      )),
    );
  }
}

