import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_list/radio_provider.dart';
import 'package:to_do_list/radio_widget.dart';
import 'package:to_do_list/service_provider.dart';
import 'package:to_do_list/textfield_widget.dart';
import 'package:to_do_list/todo_model.dart';
import 'app-style.dart';
import 'date_time_provider.dart';
import 'date_time_widget.dart';

class AddNewTaskModel extends ConsumerStatefulWidget {
  AddNewTaskModel({Key? key}) : super(key: key);

  @override
  _AddNewTaskModelState createState() => _AddNewTaskModelState();
}

class _AddNewTaskModelState extends ConsumerState<AddNewTaskModel> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed from the widget tree
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateProv = ref.watch(dateProvider) ?? 'No date selected';
    final timeProv = ref.watch(timeProvider) ?? 'No time selected';

    return SingleChildScrollView( // Wrap in a SingleChildScrollView
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: double.infinity,
              child: Text(
                'New Task Todo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const Divider(
              thickness: 1.2,
              color: Colors.grey,
            ),
            const Gap(12),
            const Text('Title Task', style: AppStyle.headingOne),
            const Gap(6),
            TextFieldWidget(
              maxLine: 1,
              hintText: 'Add Task name',
              txtController: titleController,
            ),
            const Gap(12),
            const Text('Description', style: AppStyle.headingOne),
            const Gap(6),
            TextFieldWidget(
              maxLine: 5,
              hintText: 'Add Description',
              txtController: descriptionController,
            ),
            const Gap(12),
            const Text('Category', style: AppStyle.headingOne),
            Row(
              children: [
                Expanded(
                  child: RadioWidget(
                    categColor: Colors.green,
                    titleRadio: 'LRN',
                    valueInput: 1,
                    onChangedValue: () => ref.read(radioProvider.notifier).update((state) => 1),
                  ),
                ),
                Expanded(
                  child: RadioWidget(
                    categColor: Colors.blue.shade700,
                    titleRadio: 'WRK',
                    valueInput: 2,
                    onChangedValue: () => ref.read(radioProvider.notifier).update((state) => 2),
                  ),
                ),
                Expanded(
                  child: RadioWidget(
                    categColor: Colors.amberAccent.shade700,
                    titleRadio: 'GEN',
                    valueInput: 3,
                    onChangedValue: () => ref.read(radioProvider.notifier).update((state) => 3),
                  ),
                ),
              ],
            ),
            const Gap(12),
            // Date and time section
            //date and time section

            Row(
                mainAxisAlignment : MainAxisAlignment.spaceBetween,
                children : [
                  DateTimeWidget(
                    titleText: 'Date',
                    valueText: dateProv,
                    iconSection: CupertinoIcons.calendar,
                    onTap: () async{
                      final getValue= await
                      showDatePicker(
                          context: context ,
                          initialDate: DateTime.now()
                          , firstDate: DateTime(2020),
                          lastDate: DateTime(2026));

                      if(getValue != null){
                        final format = DateFormat.yMd();
                        ref.read(dateProvider.notifier)
                            .update((state) => format.format(getValue));
                      }
                    },
                  ),
                  Gap(22),
                  DateTimeWidget(
                      titleText: 'Time',
                      valueText: ref.watch(timeProvider),
                      iconSection: CupertinoIcons.clock,
                      onTap: () async
                      {
                        final getTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now());
                        showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now());

                        if(getTime != null){
                          ref.
                          read(timeProvider.notifier).
                          update((state) => getTime.format(context));
                        }
                      }
                  ),
                ]
            ),
            const Gap(12),
            //Button Section
            Row(
                children : [
                  Expanded(
                    child :
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context) ,
                      child: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade800,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side : BorderSide(
                          color: Colors.blue.shade800,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  const Gap(20),

                  Expanded(
                    child : ElevatedButton(
                      onPressed: ()
                      {
                        final getRadioValue = ref.read(radioProvider);
                        String category = '';

                        switch(getRadioValue)
                        {
                          case 1 :
                            category = 'Learning';
                            break;
                          case 2 :
                            category = 'Working';
                            break;
                          case 3 :
                            category = 'General';
                            break;
                        }

                        ref.read(serviceProvider).addNewTask(
                            TodoModel(
                              titleTask: titleController.text,
                              description: descriptionController.text,
                              category: category,
                              dateTask: ref.read(dateProvider),
                              timeTask: ref.read(timeProvider),
                              isDone : false,
                            ));
                        print('Data is saving');

                        titleController.clear();
                        descriptionController.clear();
                        ref.read(radioProvider.notifier).update((state) => 0 );
                        Navigator.pop(context);
                      },
                      child: const Text('Create'),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side : BorderSide(
                          color: Colors.blue.shade800,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ])
          ]
        ),
      )
    );
  }
}

