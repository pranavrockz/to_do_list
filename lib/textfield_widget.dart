import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({
    Key? key,
    required this.maxLine,
    required this.hintText,
    required this.txtController,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  final String hintText;
  final int maxLine;
  final TextEditingController txtController;
  final String? Function(String?)? validator; // Optional validator
  final void Function(String)? onChanged; // Callback for text changes
  final void Function(String)? onSubmitted; // Callback for submission
  final TextInputType keyboardType; // Specify keyboard type

  @override
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  String? errorText;

  @override
  void initState() {
    super.initState();
    // Listen for changes in the text field to handle validation
    widget.txtController.addListener(() {
      if (widget.onChanged != null) {
        widget.onChanged!(widget.txtController.text);
      }
      // Validate if a validator is provided
      if (widget.validator != null) {
        setState(() {
          errorText = widget.validator!(widget.txtController.text);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          TextField(
            controller: widget.txtController,
            decoration: InputDecoration(
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: widget.hintText,
              errorText: errorText, // Show error text if validation fails
            ),
            maxLines: widget.maxLine,
            keyboardType: widget.keyboardType,
            onSubmitted: (value) {
              if (widget.onSubmitted != null) {
                widget.onSubmitted!(value);
              }
            },
          ),
          if (errorText != null) // Show the error message below the TextField
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                errorText!,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.txtController.removeListener(() {}); // Clean up listener
    super.dispose();
  }
}
