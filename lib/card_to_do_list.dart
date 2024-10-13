import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:to_do_list/service_provider.dart';

class CardTodoListWidget extends ConsumerWidget {
  const CardTodoListWidget({
    super.key,
    required this.getIndex,
  });

  final int getIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref)
  {
    final todoData = ref.watch(fetchStreamProvider);
    
    return todoData.when(
      data: (todoData) {
        Color categoryColor = Colors.white;
        // Ensure todoData is not empty and get the specific item
        if (todoData.isEmpty || getIndex < 0 || getIndex >= todoData.length) {
          return const Text('No data available');
        }

        // Access the specific TodoModel item
        final todoItem = todoData[getIndex];

        // Parse the string to DateTime in dd/mm/yyyy format
        print(todoItem.dateTask);
        final DateTime creationTime = _parseDate(todoItem.dateTask);
        final Duration duration = DateTime.now().difference(creationTime);

        // Format the duration into a string
        String durationText = _formatDuration(duration);

        final getCategory = todoData[getIndex].category;

        switch (getCategory) {
          case 'Learning':
            categoryColor = Colors.green;
            break;
          case 'Working':
            categoryColor = Colors.blue.shade200;
            break;
          case 'General':
            categoryColor = Colors.amber.shade700;
            break;
        }

        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: categoryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  width: 20,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: IconButton(
                            onPressed: () => ref
                                .read(serviceProvider)
                                .deleteTask(todoData[getIndex].docID),
                            icon: const Icon(CupertinoIcons.delete),
                          ),
                          title: Text(
                            todoData[getIndex].titleTask,
                            maxLines: 1,
                            style: TextStyle(
                              decoration: todoData[getIndex].isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            todoData[getIndex].description,
                            maxLines: 1,
                            style: TextStyle(
                              decoration: todoData[getIndex].isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          trailing: Transform.scale(
                            scale: 1.5,
                            child: Checkbox(
                              activeColor: Colors.blue.shade200,
                              shape: const CircleBorder(),
                              value: todoData[getIndex].isDone,
                              onChanged: (value) => ref
                                  .read(serviceProvider)
                                  .updateTask(todoData[getIndex].docID, value!),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -12),
                          child: Column(
                            children: [
                              Divider(
                                thickness: 1.5,
                                color: Colors.grey.shade200,
                              ),
                              Row(
                                children: [
                                  const Text('Today'),
                                  const Gap(12),
                                  Text(todoData[getIndex].timeTask),
                                  const Gap(12), // Add a gap before the duration text
                                  //Text(durationText), // Display the calculated duration
                                ],

                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      error: (error, stackTrace) => const Center(child: Text('Error')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

DateTime _parseDate(String dateString) {
  try {
    // Ensure the date string is in the expected format and trim spaces
    List<String> parts = dateString.trim().split('/');

    // Check that we have exactly 3 parts
    if (parts.length != 3) {
      throw FormatException("Invalid date format. Expected format: dd/mm/yyyy");
    }

    // Parse day, month, and year
    int day = int.parse(parts[0].trim());   // dd
    int month = int.parse(parts[1].trim()); // mm
    int year = int.parse(parts[2].trim());  // yyyy

    // Check for valid ranges
    if (day < 1 || day > 31 || month < 1 || month > 12) {
      throw FormatException("Day or month out of range");
    }

    // Handle month-day validation for different month lengths
    if ((month == 4 || month == 6 || month == 9 || month == 11) && day == 31) {
      throw FormatException("Invalid date: $day/$month/$year has only 30 days");
    }
    if (month == 2) { // February
      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      if (day > 29 || (day == 29 && !isLeapYear)) {
        throw FormatException("Invalid date: $day/$month/$year does not exist");
      }
    }

    // Create and return the DateTime object
    return DateTime(year, month, day);
  } catch (e) {
    // Handle any parsing errors
    throw FormatException("Error parsing date: ${e.toString()}");
  }
}


String _formatDuration(Duration duration) {
  if (duration.inDays > 0) {
    return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''} ago';
  } else if (duration.inHours > 0) {
    return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''} ago';
  } else if (duration.inMinutes > 0) {
    return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''} ago';
  } else {
    return 'Just now';
  }
}

