import 'package:flutter/material.dart';
class CustomTextField extends StatelessWidget {
  CustomTextField({this.hint,this.maxLines=1,this.onSaved,this.onChanged});
  final String? hint;
   var maxLines;
  final void Function(String?)? onSaved;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      onSaved: onSaved,
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'field is required';
        }else{
          return null;
        }
      },
      maxLines: maxLines,

      cursorWidth: 4,
      decoration: InputDecoration(

          hintText: hint,

          border: buildBorder(context),

          enabledBorder: buildBorder(context)),
    );
  }
}

OutlineInputBorder buildBorder(context,[ width]) {
  return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        width: width ?? 1,
        color: Theme.of(context).iconTheme.color!,
      ));
}