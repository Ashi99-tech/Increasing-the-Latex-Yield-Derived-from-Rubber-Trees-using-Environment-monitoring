import 'package:flutter/material.dart';
import 'package:rubber_lk/Components/text_field_container.dart';

class RoundedPasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const RoundedPasswordField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        obscureText: true,
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: "Password",
          icon: Icon(Icons.lock),
          suffixIcon: Icon(Icons.visibility),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
