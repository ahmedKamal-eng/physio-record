import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class CustomTextField extends StatelessWidget {
  CustomTextField({this.hint,this.maxLines=1,this.suffixButton,this.inputFormatters,this.enabled =true,this.keyboardType,this.controller,this.isRequired=true,this.onSaved,this.onChanged});
  final String? hint;

   var maxLines;
   bool isRequired;
   Widget? suffixButton;
   TextEditingController? controller;
   TextInputType? keyboardType;
   bool enabled;
   List<TextInputFormatter>? inputFormatters;
  final void Function(String?)? onSaved;
  final Function(String)? onChanged;



  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters:  inputFormatters,
      onChanged: onChanged,
      onSaved: onSaved,
      validator: (value) {
        if(isRequired){
        if (value?.isEmpty ?? true) {
          return 'field is required';
        }
        }else{
          return null;
        }
      },
      maxLines: maxLines,

      cursorWidth: 4,
      decoration: InputDecoration(
        focusColor: Colors.blue,

        contentPadding: EdgeInsets.only(bottom: 25,top: 1,right: 15,left: 15),
        suffix: suffixButton,

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
        color: Colors.black,

      ));
}